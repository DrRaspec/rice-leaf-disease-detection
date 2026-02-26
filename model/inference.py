import json
from functools import lru_cache
from pathlib import Path

import numpy as np
import tensorflow as tf
from PIL import Image

from model.config import CLASS_NAMES_PATH, IMAGE_SIZE, MODEL_PATH


@lru_cache(maxsize=1)
def _load_class_names(path: Path) -> list[str]:
    if not path.exists():
        raise FileNotFoundError(f"Class names not found: {path}")
    with path.open("r", encoding="utf-8") as f:
        names = json.load(f)
    if not isinstance(names, list) or not names:
        raise ValueError("Class names file is invalid.")
    return names


def _prepare_image(image: Image.Image) -> np.ndarray:
    image = image.convert("RGB").resize(IMAGE_SIZE)
    arr = np.asarray(image, dtype=np.float32)
    return np.expand_dims(arr, axis=0)


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

    input_tensor = _prepare_image(image)
    probs = model.predict(input_tensor, verbose=0)[0]

    best_idx = int(np.argmax(probs))
    sorted_idx = np.argsort(probs)[::-1][:top_k]
    top_predictions = [
        {"class": class_names[int(i)], "confidence": float(probs[int(i)])}
        for i in sorted_idx
    ]

    return {
        "predicted_class": class_names[best_idx],
        "confidence": float(probs[best_idx]),
        "top_predictions": top_predictions,
    }
