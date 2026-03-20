# Disease Catalog Sync Workflow

This project now uses one canonical source for disease copy:

- `data/disease_catalog.json`

Generated targets:
- `spring-api/src/main/java/com/rice/disease/service/DiseaseInfoCatalog.java`
- `mobile/lib/features/result/controllers/disease_info_catalog.dart`

## Commands

Check sync:

```bash
python scripts/sync_disease_catalogs.py --check
```

Write synced output:

```bash
python scripts/sync_disease_catalogs.py --write
```

Translation consistency is enforced by checking sync before release:

```bash
python scripts/sync_disease_catalogs.py --check
```
