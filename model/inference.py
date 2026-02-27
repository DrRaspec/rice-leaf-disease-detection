import json
import zlib
from functools import lru_cache
from pathlib import Path

import numpy as np
import tensorflow as tf
from PIL import Image, ImageOps

from model.config import CLASS_NAMES_PATH, IMAGE_SIZE, MODEL_PATH
from model.train import WarmupCosineDecay  # noqa: F401 — needed for Keras deserialization

UNCERTAIN_CONFIDENCE_THRESHOLD = 0.50
UNCERTAIN_MARGIN_THRESHOLD = 0.10
UNCERTAIN_TTA_DISAGREEMENT_THRESHOLD = 0.25
UNCERTAIN_DARK_BACKGROUND_THRESHOLD = 0.35
_RESAMPLING = getattr(Image, "Resampling", Image)


@lru_cache(maxsize=1)
def _load_class_names(path: Path) -> list[str]:
    if not path.exists():
        raise FileNotFoundError(f"Class names not found: {path}")
    with path.open("r", encoding="utf-8") as f:
        names = json.load(f)
    if not isinstance(names, list) or not names:
        raise ValueError("Class names file is invalid.")
    return names


def _center_crop_to_square(image: Image.Image) -> Image.Image:
    rgb = image.convert("RGB")
    w, h = rgb.size
    side = min(w, h)
    left = (w - side) // 2
    top = (h - side) // 2
    return rgb.crop((left, top, left + side, top + side))


def _center_crop(image: Image.Image, scale: float) -> Image.Image:
    w, h = image.size
    crop_w = max(1, int(w * scale))
    crop_h = max(1, int(h * scale))
    left = (w - crop_w) // 2
    top = (h - crop_h) // 2
    return image.crop((left, top, left + crop_w, top + crop_h))


def _fit_to_square(image: Image.Image) -> Image.Image:
    return ImageOps.fit(
        image.convert("RGB"),
        IMAGE_SIZE,
        method=_RESAMPLING.BILINEAR,
        centering=(0.5, 0.5),
    )


def _spatial_square_crops(image: Image.Image) -> list[Image.Image]:
    """Sample multiple regions so lesions near edges/tips are not discarded."""
    rgb = image.convert("RGB")
    w, h = rgb.size
    side = min(w, h)
    max_x = max(0, w - side)
    max_y = max(0, h - side)

    positions = {
        (0, 0),
        (max_x, 0),
        (0, max_y),
        (max_x, max_y),
        (max_x // 2, max_y // 2),
    }

    crops: list[Image.Image] = []
    for left, top in positions:
        crops.append(rgb.crop((left, top, left + side, top + side)))
    return crops


def _prepare_image(image: Image.Image) -> np.ndarray:
    """Resize to model input size. No manual preprocessing needed — the model
    includes preprocessing internally (include_preprocessing=True)."""
    image = image.convert("RGB").resize(IMAGE_SIZE, _RESAMPLING.BILINEAR)
    arr = np.asarray(image, dtype=np.float32)
    return np.expand_dims(arr, axis=0)


def _tta_views(image: Image.Image) -> list[Image.Image]:
    base = image.convert("RGB")
    views: list[Image.Image] = [_fit_to_square(base)]

    for square in _spatial_square_crops(base):
        views.append(square)
        views.append(square.transpose(Image.FLIP_LEFT_RIGHT))
        for scale in (0.95, 0.85):
            crop = _center_crop(square, scale)
            views.append(crop)

    # Deduplicate by content hash to avoid repeated identical views
    unique: dict[int, Image.Image] = {}
    for view in views:
        arr = np.asarray(view.resize((32, 32), _RESAMPLING.BILINEAR), dtype=np.uint8)
        key = zlib.crc32(arr.tobytes())
        unique[key] = view

    return list(unique.values())


def _tta_disagreement(per_view_probs: np.ndarray) -> float:
    """0.0 = all TTA views agree on same top class, 1.0 = complete disagreement."""
    per_view_top = np.argmax(per_view_probs, axis=1)
    counts = np.bincount(per_view_top, minlength=per_view_probs.shape[1])
    majority = int(np.max(counts)) if counts.size else 0
    return 1.0 - (majority / max(1, len(per_view_top)))


def _dark_background_ratio(image: Image.Image) -> float:
    """Heuristic for studio/isolated backgrounds (often out-of-distribution for field data)."""
    arr = np.asarray(image.convert("RGB"), dtype=np.uint8)
    is_dark = np.all(arr <= 20, axis=-1)
    return float(np.mean(is_dark))


@lru_cache(maxsize=1)
def _load_model(path: Path) -> tf.keras.Model:
    if not path.exists():
        raise FileNotFoundError(
            f"Model not found at '{path}'. Train first with: python -m model.train"
        )
    return tf.keras.models.load_model(path)


def predict_image(image: Image.Image, top_k: int = 3) -> dict:
    model = _load_model(MODEL_PATH)
    class_names = _load_class_names(CLASS_NAMES_PATH)

    views = _tta_views(image)
    probs_stack = []
    for view in views:
        input_tensor = _prepare_image(view)
        probs_stack.append(model.predict(input_tensor, verbose=0)[0])
    per_view_probs = np.stack(probs_stack, axis=0)
    probs = np.mean(per_view_probs, axis=0)

    best_idx = int(np.argmax(probs))
    sorted_idx = np.argsort(probs)[::-1][:top_k]
    top_predictions = [
        {"class": class_names[int(i)], "confidence": float(probs[int(i)])}
        for i in sorted_idx
    ]

    best_conf = float(probs[best_idx])
    second_conf = float(probs[int(sorted_idx[1])]) if len(sorted_idx) > 1 else 0.0
    margin = best_conf - second_conf
    tta_disagreement = _tta_disagreement(per_view_probs)
    dark_background_ratio = _dark_background_ratio(_center_crop_to_square(image))
    is_uncertain = (
        best_conf < UNCERTAIN_CONFIDENCE_THRESHOLD
        or margin < UNCERTAIN_MARGIN_THRESHOLD
        or tta_disagreement > UNCERTAIN_TTA_DISAGREEMENT_THRESHOLD
        or dark_background_ratio > UNCERTAIN_DARK_BACKGROUND_THRESHOLD
    )

    return {
        "predicted_class": class_names[best_idx],
        "confidence": best_conf,
        "top_predictions": top_predictions,
        "is_uncertain": is_uncertain,
        "possible_classes": [class_names[int(i)] for i in sorted_idx[:2]],
        "confidence_margin": float(margin),
        "tta_disagreement": float(tta_disagreement),
        "dark_background_ratio": float(dark_background_ratio),
    }
