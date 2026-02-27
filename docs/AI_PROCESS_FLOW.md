# AI Process Flow (RiceGuard)

This document explains the actual AI pipeline used by this project, matching the current code.

## 1) Problem and Classes

The model is a 6-class rice leaf classifier:

1. `bacterial_leaf_blight`
2. `brown_spot`
3. `healthy`
4. `leaf_blast`
5. `leaf_scald`
6. `narrow_brown_spot`

Class names are saved in `artifacts/class_names.json` and loaded during inference.

## 2) Data Layout

Training expects this folder structure:

- `dataset/train/<class_name>/*.jpg|png...`
- `dataset/validation/<class_name>/*.jpg|png...`

Config is defined in `model/config.py`:

- Image size: `260×260`
- Batch size: `16` (reduced for larger EfficientNetV2-S backbone)
- Epochs: `50` (with early stopping, patience=8)
- Random seed: `42`
- Mixup alpha: `0.2`
- Label smoothing: `0.1`

## 3) Training Pipeline

Training entrypoint: `python -m model.train` (`model/train.py`)

### Model Architecture

- Backbone: `EfficientNetV2-S` pretrained on ImageNet (`include_top=False`, `include_preprocessing=True`)
- Preprocessing: handled internally by the backbone — raw `[0, 255]` images can be passed directly (no manual `preprocess_input` call needed)
- Head:
  - `GlobalAveragePooling2D`
  - `BatchNormalization`
  - `Dropout(0.4)`
  - `Dense(256, ReLU, L2=1e-4)`
  - `Dropout(0.3)`
  - `Dense(num_classes, softmax)`

### Data Augmentation

Applied during training (as Keras preprocessing layers):

- Random horizontal and vertical flip
- Random rotation (`0.20`)
- Random contrast (`0.3`)
- Random brightness (`0.2`)
- Random zoom (`±0.15`)
- Random translation (`0.1`)

Additionally, **Mixup** (α=0.2) is applied per-batch after loading. Mixup blends pairs of images and their one-hot labels, which forces the model to learn smoother decision boundaries and improves generalization — particularly important for visually similar classes like `brown_spot` vs `narrow_brown_spot`.

### Training Strategy

Two-phase transfer learning:

1. **Warm-up** (~10 epochs): backbone fully frozen, only the classification head trains.
2. **Fine-tuning** (~40 epochs): last 60 backbone layers unfrozen. BatchNorm layers remain frozen for training stability. Earlier backbone layers stay frozen to preserve low-level ImageNet features.

### Optimization and Model Selection

- Optimizer: Adam with **cosine annealing + linear warmup** schedule
  - Warm-up phase: peaks at `1e-3`, warms up over 2 epochs
  - Fine-tune phase: peaks at `1e-5`, warms up over 1 epoch
- Loss: Categorical cross-entropy with label smoothing (`0.1`)
- Labels: One-hot encoded (required for Mixup and label smoothing)
- Metrics:
  - `accuracy`
  - `top2_accuracy`
- Best checkpoint selected by `val_accuracy`
- Early stopping: patience `8`, restores best weights

### Artifacts Produced

- `artifacts/rice_disease_model.keras`
- `artifacts/class_names.json`

## 4) Evaluation Pipeline

Evaluation entrypoint: `python -m model.evaluate` (`model/evaluate.py`)

- No manual preprocessing needed — the saved model includes preprocessing internally (`include_preprocessing=True`), so raw `[0, 255]` images are passed directly.

Outputs:

- Overall validation accuracy
- Per-class precision/recall/F1 classification report
- Row-normalized confusion matrix
- Saved files:
  - `artifacts/confusion_matrix_validation.txt`
  - `artifacts/confusion_matrix_validation.png`

## 5) Inference Pipeline (Single Image)

Main logic: `model/inference.py`

### Step-by-step

1. Load model from `artifacts/rice_disease_model.keras`.
2. Load class names from `artifacts/class_names.json`.
3. Build multiple test-time augmentation (TTA) views:
   - full-image fit-to-square view
   - multiple spatial square crops (corners + center)
   - horizontal flips
   - center crops at 95% and 85% for each region
4. For each view: resize to `260×260`, convert to float32 array, and run model prediction (no manual preprocessing — model handles it internally).
5. Average probabilities across all views (region-aware voting).
6. Return:
   - top class (`predicted_class`)
   - confidence
   - top-k predictions
   - uncertainty fields

### Uncertainty Rule

Prediction is flagged uncertain if any of:

- Best confidence `< 0.50`, or
- Margin between top-1 and top-2 `< 0.10`, or
- TTA view disagreement is high (`> 0.25`), or
- Dark background ratio is high (`> 0.35`) indicating possible out-of-distribution studio-like image

Returned fields:

- `is_uncertain` (boolean)
- `possible_classes` (top 2 labels)
- `confidence_margin`
- `tta_disagreement`
- `dark_background_ratio`

## 6) Backend and App Flow

### Spring API path (recommended)

1. Client uploads image to `POST /api/v1/predict` (`spring-api/.../PredictionController.java`).
2. Spring validates size/type and saves temp file.
3. Spring runs Python module:
   - `python -m model.predict_cli --image <temp> --top-k 3`
4. `model/predict_cli.py` opens image and calls `predict_image(...)`.
5. JSON result is returned to client.

### Client behavior

- Web: `web/src/composables/usePrediction.js`
- Mobile: `mobile/lib/app/core/api_client.dart`

Both clients show disease info and display low-confidence warning using `is_uncertain` and `possible_classes`.

## 7) How to Explain to Teacher (Short Version)

You can present it as:

1. "We use transfer learning with EfficientNetV2-S for 6 rice disease classes."
2. "Training is two-phase: frozen backbone warm-up, then partial fine-tuning with cosine annealing LR."
3. "We use Mixup augmentation and label smoothing to prevent overfitting on our small dataset."
4. "The classification head includes BatchNorm + Dense(256) for better feature discrimination."
5. "Inference uses test-time augmentation and probability averaging for robustness."
6. "We expose confidence and uncertainty to avoid over-trusting weak predictions."
7. "Model quality is validated using per-class metrics and confusion matrix, not accuracy alone."

## 8) Current Limitations

- Performance is measured on the provided validation set; true field generalization still depends on real-world image diversity.
- Similar diseases (for example `brown_spot` vs `narrow_brown_spot`) can still overlap visually in difficult photos.
- Mixup and stronger augmentation help but cannot fully compensate for a small dataset (350 images/class).
- Best practice is to use the app result as decision support, then confirm in field context.
