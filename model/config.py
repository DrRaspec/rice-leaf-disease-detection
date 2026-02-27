from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATASET_DIR = PROJECT_ROOT / "dataset"
TRAIN_DIR = DATASET_DIR / "train"
VALIDATION_DIR = DATASET_DIR / "validation"

ARTIFACTS_DIR = PROJECT_ROOT / "artifacts"
MODEL_PATH = ARTIFACTS_DIR / "rice_disease_model.keras"
CLASS_NAMES_PATH = ARTIFACTS_DIR / "class_names.json"

IMAGE_SIZE = (260, 260)
BATCH_SIZE = 16
EPOCHS = 50
SEED = 42

LEARNING_RATE = 1e-3
FINE_TUNE_LR = 1e-5
LABEL_SMOOTHING = 0.1
MIXUP_ALPHA = 0.2
