import json
import math
from collections import Counter

import numpy as np
import tensorflow as tf
from sklearn.utils.class_weight import compute_class_weight

from model.config import (
    ARTIFACTS_DIR,
    BATCH_SIZE,
    CLASS_NAMES_PATH,
    EPOCHS,
    FINE_TUNE_LR,
    IMAGE_SIZE,
    LABEL_SMOOTHING,
    LEARNING_RATE,
    MIXUP_ALPHA,
    MODEL_PATH,
    SEED,
    TRAIN_DIR,
    VALIDATION_DIR,
)


# ---------------------------------------------------------------------------
# Cosine decay with warmup
# ---------------------------------------------------------------------------

import keras.saving

@keras.saving.register_keras_serializable()
class WarmupCosineDecay(tf.keras.optimizers.schedules.LearningRateSchedule):
    """Cosine annealing with linear warmup."""

    def __init__(self, base_lr: float, total_steps: int, warmup_steps: int):
        super().__init__()
        self.base_lr = base_lr
        self.total_steps = total_steps
        self.warmup_steps = warmup_steps

    def __call__(self, step):
        step = tf.cast(step, tf.float32)
        warmup = tf.cast(self.warmup_steps, tf.float32)
        total = tf.cast(self.total_steps, tf.float32)
        warmup_lr = self.base_lr * (step / tf.maximum(warmup, 1.0))
        progress = (step - warmup) / tf.maximum(total - warmup, 1.0)
        cosine_lr = self.base_lr * 0.5 * (1.0 + tf.cos(math.pi * progress))
        return tf.where(step < warmup, warmup_lr, cosine_lr)

    def get_config(self):
        return {
            "base_lr": self.base_lr,
            "total_steps": self.total_steps,
            "warmup_steps": self.warmup_steps,
        }


# ---------------------------------------------------------------------------
# Data augmentation layer
# ---------------------------------------------------------------------------

def _build_augmentation() -> tf.keras.Sequential:
    return tf.keras.Sequential(
        [
            tf.keras.layers.RandomFlip("horizontal_and_vertical"),
            tf.keras.layers.RandomRotation(0.20),
            tf.keras.layers.RandomContrast(0.3),
            tf.keras.layers.RandomBrightness(factor=0.2),
            tf.keras.layers.RandomZoom(height_factor=(-0.15, 0.15), width_factor=(-0.15, 0.15)),
            tf.keras.layers.RandomTranslation(height_factor=0.1, width_factor=0.1),
        ],
        name="augmentation",
    )


# ---------------------------------------------------------------------------
# Mixup augmentation
# ---------------------------------------------------------------------------

def _mixup_batch(images: tf.Tensor, labels: tf.Tensor, alpha: float = 0.2):
    """Apply Mixup to a batch of images and one-hot labels.

    Blends pairs of images and their labels using a Beta-distributed weight,
    forcing the model to learn smoother decision boundaries.
    """
    batch_size = tf.shape(images)[0]
    # Sample lambda from Beta(alpha, alpha) using the gamma distribution trick
    gamma_1 = tf.random.gamma(shape=[batch_size, 1, 1, 1], alpha=alpha)
    gamma_2 = tf.random.gamma(shape=[batch_size, 1, 1, 1], alpha=alpha)
    lam = gamma_1 / (gamma_1 + gamma_2 + 1e-7)

    # Reshape lambda for label mixing (batch_size, 1)
    lam_labels = tf.reshape(lam, [batch_size, 1, 1, 1])
    lam_labels = tf.squeeze(lam_labels, axis=[2, 3])  # (batch_size, 1)

    # Shuffle indices to create pairs
    indices = tf.random.shuffle(tf.range(batch_size))
    shuffled_images = tf.gather(images, indices)
    shuffled_labels = tf.gather(labels, indices)

    mixed_images = lam * images + (1.0 - lam) * shuffled_images
    mixed_labels = lam_labels * labels + (1.0 - lam_labels) * shuffled_labels

    return mixed_images, mixed_labels


# ---------------------------------------------------------------------------
# Model builder
# ---------------------------------------------------------------------------

def build_model(num_classes: int) -> tuple[tf.keras.Model, tf.keras.Model]:
    """Build EfficientNetV2S with a deeper classification head.

    Uses include_preprocessing=True so the backbone handles input rescaling
    internally — raw [0, 255] images can be passed directly.
    """
    inputs = tf.keras.Input(shape=(*IMAGE_SIZE, 3))

    # Augmentation (active during training only, expects [0, 255] input)
    x = _build_augmentation()(inputs)

    backbone = tf.keras.applications.EfficientNetV2S(
        include_top=False,
        weights="imagenet",
        input_shape=(*IMAGE_SIZE, 3),
        include_preprocessing=True,
    )
    backbone.trainable = False

    x = backbone(x, training=False)
    x = tf.keras.layers.GlobalAveragePooling2D()(x)
    x = tf.keras.layers.BatchNormalization()(x)
    x = tf.keras.layers.Dropout(0.4)(x)
    x = tf.keras.layers.Dense(256, activation="relu", kernel_regularizer=tf.keras.regularizers.l2(1e-4))(x)
    x = tf.keras.layers.Dropout(0.3)(x)
    outputs = tf.keras.layers.Dense(num_classes, activation="softmax")(x)

    model = tf.keras.Model(inputs, outputs)
    return model, backbone


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _extract_labels(dataset: tf.data.Dataset) -> np.ndarray:
    labels: list[int] = []
    for _, batch_labels in dataset:
        labels.extend(int(v) for v in batch_labels.numpy().tolist())
    return np.array(labels, dtype=np.int32)


def _build_class_weights(labels: np.ndarray) -> dict[int, float]:
    classes = np.unique(labels)
    weights = compute_class_weight(class_weight="balanced", classes=classes, y=labels)
    return {int(cls): float(w) for cls, w in zip(classes, weights)}


# ---------------------------------------------------------------------------
# Training entrypoint
# ---------------------------------------------------------------------------

def train() -> None:
    if not TRAIN_DIR.exists() or not VALIDATION_DIR.exists():
        raise FileNotFoundError(
            f"Expected dataset folders at '{TRAIN_DIR}' and '{VALIDATION_DIR}'."
        )

    tf.keras.utils.set_random_seed(SEED)
    ARTIFACTS_DIR.mkdir(parents=True, exist_ok=True)

    # ---- Load datasets with int labels for class weight computation ----
    train_ds_int = tf.keras.utils.image_dataset_from_directory(
        TRAIN_DIR,
        labels="inferred",
        label_mode="int",
        color_mode="rgb",
        batch_size=BATCH_SIZE,
        image_size=IMAGE_SIZE,
        shuffle=True,
        seed=SEED,
    )
    class_names = train_ds_int.class_names
    num_classes = len(class_names)
    train_labels = _extract_labels(train_ds_int)
    class_counts = Counter(train_labels.tolist())
    class_weights = _build_class_weights(train_labels)

    print("Class distribution:")
    for idx, name in enumerate(class_names):
        print(
            f"  {name}: count={class_counts.get(idx, 0)} class_weight={class_weights.get(idx, 1.0):.3f}"
        )

    # ---- Load with categorical (one-hot) labels for label smoothing + Mixup ----
    train_ds = tf.keras.utils.image_dataset_from_directory(
        TRAIN_DIR,
        labels="inferred",
        label_mode="categorical",
        color_mode="rgb",
        batch_size=BATCH_SIZE,
        image_size=IMAGE_SIZE,
        shuffle=True,
        seed=SEED,
    )

    val_ds = tf.keras.utils.image_dataset_from_directory(
        VALIDATION_DIR,
        labels="inferred",
        label_mode="categorical",
        color_mode="rgb",
        batch_size=BATCH_SIZE,
        image_size=IMAGE_SIZE,
        shuffle=False,
    )

    autotune = tf.data.AUTOTUNE

    # Apply Mixup to training data
    def apply_mixup(images, labels):
        return _mixup_batch(images, labels, alpha=MIXUP_ALPHA)

    train_ds = train_ds.map(apply_mixup, num_parallel_calls=autotune).prefetch(autotune)
    val_ds = val_ds.prefetch(autotune)

    # ---- Build model ----
    model, backbone = build_model(num_classes)

    steps_per_epoch = max(1, len(train_labels) // BATCH_SIZE)

    # ---- Phase 1: Warmup (frozen backbone) ----
    warmup_epochs = min(10, max(5, EPOCHS // 3))
    fine_tune_epochs = max(0, EPOCHS - warmup_epochs)

    warmup_total_steps = steps_per_epoch * warmup_epochs
    warmup_schedule = WarmupCosineDecay(
        base_lr=LEARNING_RATE,
        total_steps=warmup_total_steps,
        warmup_steps=steps_per_epoch * 2,
    )

    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=warmup_schedule),
        loss=tf.keras.losses.CategoricalCrossentropy(label_smoothing=LABEL_SMOOTHING),
        metrics=[
            "accuracy",
            tf.keras.metrics.TopKCategoricalAccuracy(k=2, name="top2_accuracy"),
        ],
    )

    callbacks = [
        tf.keras.callbacks.EarlyStopping(
            monitor="val_accuracy", mode="max", patience=8, restore_best_weights=True
        ),
        tf.keras.callbacks.ModelCheckpoint(
            filepath=str(MODEL_PATH),
            monitor="val_accuracy",
            mode="max",
            save_best_only=True,
        ),
    ]

    print(f"\nPhase 1: Warm-up training for {warmup_epochs} epochs (frozen backbone)...")
    model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=warmup_epochs,
        class_weight=class_weights,
        callbacks=callbacks,
    )

    # ---- Phase 2: Fine-tuning (partial backbone unfreeze) ----
    if fine_tune_epochs > 0:
        backbone.trainable = True
        for layer in backbone.layers:
            if isinstance(layer, tf.keras.layers.BatchNormalization):
                layer.trainable = False

        num_layers = len(backbone.layers)
        freeze_up_to = max(0, num_layers - 60)
        for layer in backbone.layers[:freeze_up_to]:
            layer.trainable = False

        trainable_count = sum(1 for l in backbone.layers if l.trainable)
        print(f"\nPhase 2: Fine-tuning {trainable_count}/{num_layers} backbone layers for {fine_tune_epochs} epochs...")

        fine_tune_total_steps = steps_per_epoch * fine_tune_epochs
        fine_tune_schedule = WarmupCosineDecay(
            base_lr=FINE_TUNE_LR,
            total_steps=fine_tune_total_steps,
            warmup_steps=steps_per_epoch,
        )

        model.compile(
            optimizer=tf.keras.optimizers.Adam(learning_rate=fine_tune_schedule),
            loss=tf.keras.losses.CategoricalCrossentropy(label_smoothing=LABEL_SMOOTHING),
            metrics=[
                "accuracy",
                tf.keras.metrics.TopKCategoricalAccuracy(k=2, name="top2_accuracy"),
            ],
        )

        model.fit(
            train_ds,
            validation_data=val_ds,
            epochs=warmup_epochs + fine_tune_epochs,
            initial_epoch=warmup_epochs,
            class_weight=class_weights,
            callbacks=callbacks,
        )

    # ---- Save model and class names ----
    model.save(MODEL_PATH)
    with CLASS_NAMES_PATH.open("w", encoding="utf-8") as f:
        json.dump(class_names, f, indent=2)

    val_loss, val_accuracy, val_top2 = model.evaluate(val_ds, verbose=0)
    print(f"\nFinal validation loss: {val_loss:.4f}")
    print(f"Final validation accuracy: {val_accuracy:.4f}")
    print(f"Final validation top-2 accuracy: {val_top2:.4f}")
    print(f"Saved model to: {MODEL_PATH}")
    print(f"Saved class names to: {CLASS_NAMES_PATH}")


if __name__ == "__main__":
    train()
