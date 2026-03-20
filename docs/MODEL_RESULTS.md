# Model Results

This document records the verified dataset rebuild, training run, and evaluation results for the current RiceGuard model.

## Final Scope

The current classifier predicts 6 classes:

1. `bacterial_leaf_blight`
2. `brown_spot`
3. `healthy`
4. `leaf_blast`
5. `leaf_scald`
6. `narrow_brown_spot`

## Data Sources Used

Included in the rebuilt dataset:

- Baseline project split from `dedeikhsandwisaputra/rice-leafs-disease-dataset`
- Exact class matches from `vbookshelf/rice-leaf-diseases`
- Exact class matches from the original `Rice_Leaf_Diease` subset in `loki4514/rice-leaf-diseases-detection`

Excluded from the rebuild:

- `Leaf smut` from `vbookshelf`
- `hispa`, `tungro`, `sheath_blight`, and `neck_blast` from `loki4514`
- the `Rice_Leaf_AUG` augmented subset from `loki4514`
- the Kaggle competition source `paddy-disease-classification`, because competition authentication was still required

## Rebuilt Dataset Counts

Curated pool:

- `bacterial_leaf_blight`: `1809`
- `brown_spot`: `1941`
- `healthy`: `2037`
- `leaf_blast`: `2275`
- `leaf_scald`: `2063`
- `narrow_brown_spot`: `1868`

Training split:

- `bacterial_leaf_blight`: `1447`
- `brown_spot`: `1553`
- `healthy`: `1630`
- `leaf_blast`: `1820`
- `leaf_scald`: `1650`
- `narrow_brown_spot`: `1494`

Validation split:

- `bacterial_leaf_blight`: `362`
- `brown_spot`: `388`
- `healthy`: `407`
- `leaf_blast`: `455`
- `leaf_scald`: `413`
- `narrow_brown_spot`: `374`

Previous split backup:

- `dataset/backup_before_external_merge_20260320/train`: `350` per class
- `dataset/backup_before_external_merge_20260320/validation`: `88` per class

## Training Run

Training command:

```powershell
.\.venv\Scripts\python.exe -m model.train
```

Evaluation command:

```powershell
.\.venv\Scripts\python.exe -m model.evaluate
```

Model artifact:

- `artifacts/rice_disease_model.keras`

Auxiliary artifacts:

- `artifacts/class_names.json`
- `artifacts/confusion_matrix_validation.txt`
- `artifacts/confusion_matrix_validation.png`

## Evaluation Results

Validation set size: `2399`

Validation accuracy: `0.8658`

Per-class report:

| Class | Precision | Recall | F1 | Support |
|---|---:|---:|---:|---:|
| `bacterial_leaf_blight` | 0.9725 | 0.9751 | 0.9738 | 362 |
| `brown_spot` | 0.8036 | 0.8119 | 0.8077 | 388 |
| `healthy` | 0.9186 | 0.9705 | 0.9438 | 407 |
| `leaf_blast` | 0.7833 | 0.6989 | 0.7387 | 455 |
| `leaf_scald` | 0.9369 | 0.8983 | 0.9172 | 413 |
| `narrow_brown_spot` | 0.7888 | 0.8690 | 0.8270 | 374 |

Aggregate metrics:

- Macro precision: `0.8673`
- Macro recall: `0.8706`
- Macro F1: `0.8680`
- Weighted precision: `0.8654`
- Weighted recall: `0.8658`
- Weighted F1: `0.8646`

## Main Error Patterns

Largest remaining confusion areas from the normalized confusion matrix:

- `leaf_blast` predicted as `brown_spot`: `0.1473`
- `brown_spot` predicted as `narrow_brown_spot`: `0.1005`
- `narrow_brown_spot` predicted as `leaf_blast`: `0.0856`
- `leaf_blast` predicted as `narrow_brown_spot`: `0.0747`
- `leaf_scald` predicted as `leaf_blast`: `0.0630`

Strongest classes:

- `bacterial_leaf_blight`
- `healthy`
- `leaf_scald`

Weakest class:

- `leaf_blast`

## Interpretation

What is confirmed:

- The rebuilt dataset and training pipeline work end to end.
- Adding carefully filtered external data produced a much larger evaluation set than the original project split.
- The model remains strong on clearly defined classes such as `bacterial_leaf_blight` and `healthy`.

What still needs caution:

- `leaf_blast`, `brown_spot`, and `narrow_brown_spot` still overlap visually.
- This accuracy is for the rebuilt local validation split, not a fully independent field-trial benchmark.
- The blocked competition dataset was not included, so these results do not represent every possible external rice-leaf source.
