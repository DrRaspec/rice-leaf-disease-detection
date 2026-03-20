# Data Sources and References

This file documents dataset provenance for transparency, reproducibility, and publication readiness.

## Project Taxonomy

The current production classifier is intentionally limited to these 6 classes:

1. `bacterial_leaf_blight`
2. `brown_spot`
3. `healthy`
4. `leaf_blast`
5. `leaf_scald`
6. `narrow_brown_spot`

Any source that uses a different taxonomy must be mapped carefully before images are included in training.

## Primary Base Dataset

1. Rice Leafs Disease Dataset (Kaggle)  
   URL: https://www.kaggle.com/datasets/dedeikhsandwisaputra/rice-leafs-disease-dataset  
   Role in this project: Base image dataset used to build initial train/validation data.  
   Accessed: February 26, 2026

## Reviewed Expansion Candidates

1. Rice Leaf Diseases (Kaggle, vbookshelf)  
   URL: https://www.kaggle.com/datasets/vbookshelf/rice-leaf-diseases  
   Role in this project: Reviewed supplemental source. Local download confirms 3 classes: `Bacterial leaf blight`, `Brown spot`, and `Leaf smut`. Only the first two map to the current project taxonomy.  
   Accessed: March 20, 2026  
   Current status: `imported exact matches only`

2. Paddy Disease Classification / Paddy Doctor family  
   URLs:  
   - https://www.kaggle.com/competitions/paddy-disease-classification/data  
   - https://paddydoc.github.io/dataset/  
   Role in this project: Candidate source for selective import only. The broader dataset includes classes outside the project's 6-class scope, such as `bacterial_leaf_streak`, `bacterial_panicle_blight`, `hispa`, `downy_mildew`, `tungro`, and stem borers.  
   Accessed: March 20, 2026  
   Current status: `download blocked by competition authentication`

3. Rice Leaf Diseases Detection (Kaggle, loki4514)  
   URL: https://www.kaggle.com/datasets/loki4514/rice-leaf-diseases-detection  
   Role in this project: Reviewed supplemental source. Local archive inspection confirms the original subset contains the project's 6 classes plus non-project classes such as `tungro`, `sheath_blight`, `rice_hispa`, and `neck_blast`.  
   Accessed: March 20, 2026  
   Current status: `imported original exact matches only; augmented subset excluded`

## Local/Project Data

1. Project-curated train/validation split  
   Path: `dataset/train`, `dataset/validation`  
   Role in this project: Rebuilt working dataset used for model training and evaluation.

2. Curated deduplicated pool  
   Path: `dataset/curated`  
   Role in this project: Combined baseline plus approved external images before train/validation splitting.

3. Backup of previous split  
   Path: `dataset/backup_before_external_merge_20260320`  
   Role in this project: Frozen copy of the original 350/88 per-class split before external data import.

## Registry and Merge Rules

- Source review decisions are tracked in `data/dataset_source_registry.json`.
- Validate the registry before merging with `python scripts/validate_dataset_registry.py`.
- Follow the step-by-step curation rules in `docs/DATASET_EXPANSION.md`.

## Notes

- If you add Cambodia field images, list each source here (organization, date, permission, and collection method).
- For each new source, record:
  - Source name
  - URL or owner/contact
  - License/permission terms
  - Date accessed/received
  - Which classes were added
- Never mix unmatched classes into training just because the leaf images look visually similar.
- Never evaluate on images that were used for source selection, label cleanup, or duplicate filtering unless the split is rebuilt from scratch.
