# Khmer Formal Translation Notes (Rice Disease Domain)

Date: 2026-03-06

## Goal
Use Khmer wording that is clear for Cambodian agriculture users while preserving scientific accuracy.

## Source References
- MAFF e-library rice disease/pest material (Khmer): https://elibrary.maff.gov.kh/books/6659e2f9b26d788f92f7e95f
- MAFF e-library rice handbook page: https://elibrary.maff.gov.kh/ebook/93
- IRRI Rice Knowledge Bank, Bacterial Leaf Blight: http://www.knowledgebank.irri.org/training/fact-sheets/pest-management/diseases/item/bacterial-blight
- IRRI Rice Knowledge Bank, Leaf Blast: http://www.knowledgebank.irri.org/training/fact-sheets/pest-management/diseases/item/leaf-blast
- IRRI Rice Knowledge Bank, Brown Spot: http://www.knowledgebank.irri.org/training/fact-sheets/pest-management/diseases/item/brown-spot

## Standardization Decisions
- Canonical `leaf_blast` Khmer label: `ជំងឺក្រុង` (farmer-recognizable in Cambodia).
- Replace non-formal `មួក` with formal symptom verb `ស្វិត`.
- Replace English-only morphology token `(fusiform)` with Khmer-friendly explanation `(រាងពងក្រពើចុងស្រួច)`.
- Keep scientific names and fungicide actives in Latin where needed for technical clarity.

## Consistency Rule
All three catalogs must carry the same Khmer disease label and symptom wording:
- `api/main.py`
- `spring-api/.../DiseaseInfoCatalog.java`
- `mobile/.../disease_info_catalog.dart`

The sync workflow keeps this baseline aligned across all targets from one canonical source.
