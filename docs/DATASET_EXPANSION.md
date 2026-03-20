# Dataset Expansion Guide

This guide defines the safe workflow for adding more rice-leaf images to RiceGuard without weakening accuracy claims.

## Decision

Adding more data is a good idea for this project, but only when all of the following are true:

- the new images can be mapped to the existing 6-class taxonomy
- duplicates and near-duplicates are removed before splitting
- a fresh validation or test split is built after the merge
- source provenance is recorded

If those conditions are ignored, reported accuracy may look better while real-world performance gets worse.

## Current Model Scope

The current classifier supports only:

1. `bacterial_leaf_blight`
2. `brown_spot`
3. `healthy`
4. `leaf_blast`
5. `leaf_scald`
6. `narrow_brown_spot`

Do not silently add new diseases such as `hispa`, `tungro`, `sheath_blight`, or `bacterial_leaf_streak` unless the application, disease catalog, training code, and evaluation policy are all expanded together.

## Audit of Reviewed Candidate Sources

### 1. Kaggle: `vbookshelf/rice-leaf-diseases`

Status: `imported exact matches only`

What local inspection confirmed:

- the downloaded dataset contains `Bacterial leaf blight`, `Brown spot`, and `Leaf smut`
- only the first two classes map to the current project taxonomy
- exact duplicate hashing against the current train and validation folders found `0` exact duplicates for the approved classes

Decision:

- import `Bacterial leaf blight` into `bacterial_leaf_blight`
- import `Brown spot` into `brown_spot`
- exclude `Leaf smut`
- rebuild the train and validation split after import instead of dropping these files straight into the current folders

Reference:

- https://www.nature.com/articles/s41598-025-13079-z

### 2. Kaggle competition: `paddy-disease-classification`

Status: `blocked by competition authentication`

Why this source can help:

- Paddy Doctor is a large field-collected dataset with strong diversity
- public dataset documentation reports 16,225 cleaned images collected in real paddy fields

Why this source needs caution:

- the full dataset covers more than the project's 6 classes
- public documentation lists classes such as `bacterial_leaf_streak`, `bacterial_panicle_blight`, `blast`, `brown_spot`, `downy_mildew`, `hispa`, `leaf_roller`, `tungro`, stem borers, and `normal`

Decision:

- only import images that map cleanly into `bacterial_leaf_blight`, `brown_spot`, `healthy`, or `leaf_blast`
- do not relabel `normal` if the source includes non-leaf or mixed-quality images without manual review
- exclude all classes outside the current app taxonomy

References:

- https://paddydoc.github.io/dataset/
- https://arxiv.org/abs/2205.11108

### 3. Kaggle: `loki4514/rice-leaf-diseases-detection`

Status: `imported original exact matches only`

Why this source can help:

- local archive inspection confirms the original `Rice_Leaf_Diease` subset contains all 6 project classes
- this source adds a much larger pool of original images than the current baseline

Why this source needs caution:

- the archive also includes non-project classes such as `rice_hispa`, `tungro`, `sheath_blight`, and `neck_blast`
- the archive also includes a separate `Rice_Leaf_AUG` augmented subset, which should not be mixed in casually

Decision:

- import only the original non-augmented exact class matches
- exclude `rice_hispa`, `tungro`, `sheath_blight`, and `neck_blast`
- exclude the `Rice_Leaf_AUG` augmented subset from the default rebuild

## Safe Merge Policy

Use this sequence every time new data is added.

1. Download the dataset into a raw staging area outside `dataset/train` and `dataset/validation`.
2. Inspect the actual folder names and sample images.
3. Record the source in `data/dataset_source_registry.json`.
4. Validate the registry with `python scripts/validate_dataset_registry.py`.
5. Copy only exact or explicitly approved mappings into a curated working set.
6. Remove duplicates and near-duplicates before any train/validation split is created.
7. Rebuild the split from scratch so the same source is not leaking into both training and validation.
8. Retrain and run `python -m model.evaluate`.
9. Compare per-class precision, recall, F1, and confusion matrix before claiming improvement.

## Recommended Folder Strategy

Keep a three-stage layout:

```text
dataset/
  raw/
    <source_name>/
  curated/
    <project_class_name>/
  train/
    <project_class_name>/
  validation/
    <project_class_name>/
```

Notes:

- `raw/` keeps the original source untouched
- `curated/` contains only reviewed images mapped to the project taxonomy
- `train/` and `validation/` should be regenerated from `curated/`, not edited manually over time

## Mapping Rules

Allowed direct mappings:

- `bacterial_leaf_blight` -> `bacterial_leaf_blight`
- `brown_spot` -> `brown_spot`
- `healthy` -> `healthy`
- `leaf_blast` or `blast` -> `leaf_blast`
- `leaf_scald` -> `leaf_scald`
- `narrow_brown_spot` -> `narrow_brown_spot`
- `normal` -> `healthy` only after manual image review

Default exclusions:

- `bacterial_leaf_streak`
- `bacterial_panicle_blight`
- `false_smut`
- `neck_blast`
- `sheath_blight`
- `hispa`
- `leaf_roller`
- `tungro`
- `downy_mildew`
- `dead_heart`
- `stem_borer` variants

Why we exclude them:

- they represent different diseases, pests, or plant parts
- folding them into a nearby class would create noisy labels and lower trust in predictions

## What Improvement to Expect

If the merge is done carefully, the most likely gains are:

- better field robustness across lighting and background conditions
- better recall on rare-looking examples inside each supported class
- fewer overconfident mistakes on borderline images

On March 20, 2026, the rebuilt curated dataset reached these totals after exact deduplication:

- `bacterial_leaf_blight`: 1,809
- `brown_spot`: 1,941
- `healthy`: 2,037
- `leaf_blast`: 2,275
- `leaf_scald`: 2,063
- `narrow_brown_spot`: 1,868

The least reliable metric is a single accuracy number from the old validation split.
The most trustworthy signal is improvement on a rebuilt holdout set and cleaner confusion matrix behavior for difficult pairs like:

- `brown_spot` vs `narrow_brown_spot`
- `bacterial_leaf_blight` vs visually damaged non-matching leaves
- `healthy` vs very mild early disease

## Minimum Documentation Checklist

Before retraining with new data, update:

- `docs/DATA_SOURCES.md`
- `data/dataset_source_registry.json`
- training notes with the date of the merge
- evaluation notes with old vs new per-class metrics
