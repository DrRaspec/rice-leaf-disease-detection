#!/usr/bin/env python3
"""
Rebuild the project dataset from the current split plus reviewed external sources.

This script:
- copies the current train/validation images into a curated pool
- imports approved classes from reviewed raw sources
- removes exact duplicates using SHA-256
- creates a fresh train/validation split

Usage:
  python scripts/rebuild_dataset_from_sources.py
"""

from __future__ import annotations

import hashlib
import random
import shutil
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATASET_DIR = ROOT / "dataset"
TRAIN_DIR = DATASET_DIR / "train"
VALIDATION_DIR = DATASET_DIR / "validation"
CURATED_DIR = DATASET_DIR / "curated"
BACKUP_DIR = DATASET_DIR / "backup_before_external_merge_20260320"

PROJECT_CLASSES = [
    "bacterial_leaf_blight",
    "brown_spot",
    "healthy",
    "leaf_blast",
    "leaf_scald",
    "narrow_brown_spot",
]

VAL_RATIO = 0.2
SEED = 42


def _safe_name(text: str) -> str:
    return "".join(c if c.isalnum() or c in {"-", "_", "."} else "_" for c in text)


def _ensure_empty_dir(path: Path) -> None:
    if path.exists():
        shutil.rmtree(path)
    path.mkdir(parents=True, exist_ok=True)


def _store_payload(
    payload: bytes,
    *,
    class_name: str,
    source_slug: str,
    source_name: str,
    seen_hashes: dict[str, set[str]],
    per_class_index: dict[str, int],
    stats: dict[str, dict[str, int]],
) -> None:
    digest = hashlib.sha256(payload).hexdigest()
    if digest in seen_hashes[class_name]:
        stats[class_name]["duplicates_skipped"] += 1
        return

    seen_hashes[class_name].add(digest)
    per_class_index[class_name] += 1
    suffix = Path(source_name).suffix.lower() or ".jpg"
    filename = (
        f"{per_class_index[class_name]:05d}"
        f"__{_safe_name(source_slug)}"
        f"__{_safe_name(Path(source_name).stem)}{suffix}"
    )
    output_path = CURATED_DIR / class_name / filename
    output_path.write_bytes(payload)
    stats[class_name]["kept"] += 1


def _import_curated() -> tuple[dict[str, dict[str, int]], int]:
    stats = {
        class_name: {"kept": 0, "duplicates_skipped": 0}
        for class_name in PROJECT_CLASSES
    }
    seen_hashes = {class_name: set() for class_name in PROJECT_CLASSES}
    per_class_index = {class_name: 0 for class_name in PROJECT_CLASSES}
    source_items = 0

    _ensure_empty_dir(CURATED_DIR)
    for class_name in PROJECT_CLASSES:
        (CURATED_DIR / class_name).mkdir(parents=True, exist_ok=True)

    for split_name, base_dir in (("train", TRAIN_DIR), ("validation", VALIDATION_DIR)):
        for class_name in PROJECT_CLASSES:
            class_dir = base_dir / class_name
            if not class_dir.exists():
                continue
            for file in sorted(class_dir.iterdir()):
                if not file.is_file():
                    continue
                source_items += 1
                _store_payload(
                    file.read_bytes(),
                    class_name=class_name,
                    source_slug=f"baseline-{split_name}",
                    source_name=file.name,
                    seen_hashes=seen_hashes,
                    per_class_index=per_class_index,
                    stats=stats,
                )

    vbookshelf_root = DATASET_DIR / "raw" / "vbookshelf-rice-leaf-diseases" / "rice_leaf_diseases"
    vbookshelf_mapping = {
        "Bacterial leaf blight": "bacterial_leaf_blight",
        "Brown spot": "brown_spot",
    }
    for src_class, dst_class in vbookshelf_mapping.items():
        class_dir = vbookshelf_root / src_class
        if not class_dir.exists():
            continue
        for file in sorted(class_dir.iterdir()):
            if not file.is_file():
                continue
            source_items += 1
            _store_payload(
                file.read_bytes(),
                class_name=dst_class,
                source_slug="vbookshelf",
                source_name=file.name,
                seen_hashes=seen_hashes,
                per_class_index=per_class_index,
                stats=stats,
            )

    loki_zip = DATASET_DIR / "raw" / "loki4514-rice-leaf-diseases-detection" / "rice-leaf-diseases-detection.zip"
    if loki_zip.exists():
        approved = set(PROJECT_CLASSES)
        with zipfile.ZipFile(loki_zip) as zf:
            for info in zf.infolist():
                if info.is_dir():
                    continue
                parts = [p for p in info.filename.split("/") if p]
                if len(parts) < 5:
                    continue
                if parts[0] != "Rice_Leaf_Diease" or parts[2] not in {"train", "test"}:
                    continue
                class_name = parts[3]
                if class_name not in approved:
                    continue
                source_items += 1
                _store_payload(
                    zf.read(info),
                    class_name=class_name,
                    source_slug="loki4514-original",
                    source_name=parts[4],
                    seen_hashes=seen_hashes,
                    per_class_index=per_class_index,
                    stats=stats,
                )

    return stats, source_items


def _backup_current_split() -> None:
    if BACKUP_DIR.exists():
        shutil.rmtree(BACKUP_DIR)
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)
    shutil.copytree(TRAIN_DIR, BACKUP_DIR / "train")
    shutil.copytree(VALIDATION_DIR, BACKUP_DIR / "validation")


def _rebuild_split() -> dict[str, dict[str, int]]:
    rng = random.Random(SEED)
    _ensure_empty_dir(TRAIN_DIR)
    _ensure_empty_dir(VALIDATION_DIR)

    stats = {
        class_name: {"curated_total": 0, "train": 0, "validation": 0}
        for class_name in PROJECT_CLASSES
    }

    for class_name in PROJECT_CLASSES:
        curated_files = sorted((CURATED_DIR / class_name).iterdir())
        rng.shuffle(curated_files)
        total = len(curated_files)
        val_count = max(1, round(total * VAL_RATIO))
        if total >= 5:
            val_count = min(val_count, total - 4)
        train_files = curated_files[val_count:]
        val_files = curated_files[:val_count]

        train_class_dir = TRAIN_DIR / class_name
        val_class_dir = VALIDATION_DIR / class_name
        train_class_dir.mkdir(parents=True, exist_ok=True)
        val_class_dir.mkdir(parents=True, exist_ok=True)

        for file in train_files:
            shutil.copy2(file, train_class_dir / file.name)
        for file in val_files:
            shutil.copy2(file, val_class_dir / file.name)

        stats[class_name]["curated_total"] = total
        stats[class_name]["train"] = len(train_files)
        stats[class_name]["validation"] = len(val_files)

    return stats


def main() -> int:
    if not TRAIN_DIR.exists() or not VALIDATION_DIR.exists():
        raise FileNotFoundError("Expected existing dataset/train and dataset/validation folders.")

    import_stats, source_count = _import_curated()
    print(f"Collected source items: {source_count}")
    _backup_current_split()
    split_stats = _rebuild_split()

    print("\nImport summary:")
    for class_name in PROJECT_CLASSES:
        stats = import_stats[class_name]
        print(
            f"- {class_name}: kept={stats['kept']} duplicates_skipped={stats['duplicates_skipped']}"
        )

    print("\nRebuilt split:")
    for class_name in PROJECT_CLASSES:
        stats = split_stats[class_name]
        print(
            f"- {class_name}: curated_total={stats['curated_total']} "
            f"train={stats['train']} validation={stats['validation']}"
        )

    print(f"\nBacked up previous split to: {BACKUP_DIR}")
    print(f"Curated dataset written to: {CURATED_DIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
