import json
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf
from sklearn.metrics import classification_report, confusion_matrix

from model.config import ARTIFACTS_DIR, CLASS_NAMES_PATH, IMAGE_SIZE, MODEL_PATH, VALIDATION_DIR
from model.train import WarmupCosineDecay  # noqa: F401 — needed for Keras deserialization


def _load_class_names(path: Path) -> list[str]:
    if not path.exists():
        raise FileNotFoundError(f"Class names not found: {path}")
    with path.open("r", encoding="utf-8") as f:
        names = json.load(f)
    if not isinstance(names, list) or not names:
        raise ValueError("Class names file is invalid.")
    return names


def evaluate() -> None:
    if not MODEL_PATH.exists():
        raise FileNotFoundError(f"Model not found: {MODEL_PATH}. Train first with: python -m model.train")
    if not VALIDATION_DIR.exists():
        raise FileNotFoundError(f"Validation directory not found: {VALIDATION_DIR}")

    class_names = _load_class_names(CLASS_NAMES_PATH)
    model = tf.keras.models.load_model(MODEL_PATH)

    val_ds = tf.keras.utils.image_dataset_from_directory(
        VALIDATION_DIR,
        labels="inferred",
        label_mode="int",
        color_mode="rgb",
        batch_size=32,
        image_size=IMAGE_SIZE,
        shuffle=False,
    )

    y_true: list[int] = []
    for _, labels in val_ds:
        y_true.extend(labels.numpy().tolist())
    y_true_np = np.array(y_true, dtype=np.int32)

    # No manual preprocessing needed — model includes preprocessing internally
    probs = model.predict(val_ds, verbose=0)
    y_pred_np = np.argmax(probs, axis=1).astype(np.int32)

    overall_acc = float((y_true_np == y_pred_np).mean())
    print(f"Validation accuracy: {overall_acc:.4f}")

    print("\nClassification report:")
    print(
        classification_report(
            y_true_np,
            y_pred_np,
            target_names=class_names,
            digits=4,
            zero_division=0,
        )
    )

    cm = confusion_matrix(y_true_np, y_pred_np, labels=list(range(len(class_names))))
    cm_norm = cm.astype(np.float32) / np.maximum(cm.sum(axis=1, keepdims=True), 1)

    np.set_printoptions(precision=3, suppress=True)
    print("Confusion matrix (row-normalized):")
    print(cm_norm)

    ARTIFACTS_DIR.mkdir(parents=True, exist_ok=True)
    cm_txt = ARTIFACTS_DIR / "confusion_matrix_validation.txt"
    with cm_txt.open("w", encoding="utf-8") as f:
        f.write("Labels:\n")
        for idx, name in enumerate(class_names):
            f.write(f"{idx}: {name}\n")
        f.write("\nRow-normalized confusion matrix:\n")
        f.write(np.array2string(cm_norm, precision=4, suppress_small=True))
    print(f"Saved confusion matrix text to: {cm_txt}")

    # Visual confusion matrix
    fig, ax = plt.subplots(figsize=(8, 6))
    im = ax.imshow(cm_norm, cmap="Greens", vmin=0.0, vmax=1.0)
    ax.set_xticks(range(len(class_names)))
    ax.set_yticks(range(len(class_names)))
    ax.set_xticklabels(class_names, rotation=45, ha="right")
    ax.set_yticklabels(class_names)
    ax.set_xlabel("Predicted")
    ax.set_ylabel("True")
    ax.set_title("Validation Confusion Matrix (Normalized)")
    fig.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    fig.tight_layout()
    cm_png = ARTIFACTS_DIR / "confusion_matrix_validation.png"
    fig.savefig(cm_png, dpi=180)
    plt.close(fig)
    print(f"Saved confusion matrix figure to: {cm_png}")


if __name__ == "__main__":
    evaluate()
