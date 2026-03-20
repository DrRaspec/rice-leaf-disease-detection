#!/usr/bin/env python3
"""
Validate dataset source registry entries against the project's current taxonomy.

Usage:
  python scripts/validate_dataset_registry.py
"""

from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REGISTRY_PATH = ROOT / "data" / "dataset_source_registry.json"


def main() -> int:
    data = json.loads(REGISTRY_PATH.read_text(encoding="utf-8"))
    taxonomy = set(data["project_taxonomy"])
    sources = data["sources"]

    errors: list[str] = []

    print("Project taxonomy:")
    for label in data["project_taxonomy"]:
        print(f"- {label}")

    print("\nSource review summary:")
    for source in sources:
        slug = source["slug"]
        status = source["status"]
        mappings = source["approved_mappings"]
        excluded = source["excluded_classes"]
        taxonomy_candidates = source["source_taxonomy"]

        print(f"\n[{slug}]")
        print(f"status: {status}")
        print(f"source classes listed: {len(taxonomy_candidates)}")
        print(f"approved mappings: {len(mappings)}")
        print(f"excluded classes: {len(excluded)}")

        for src_label, dst_label in mappings.items():
            if dst_label not in taxonomy:
                errors.append(
                    f"{slug}: approved mapping '{src_label} -> {dst_label}' targets a class outside project taxonomy"
                )

        overlap = set(mappings).intersection(excluded)
        if overlap:
            errors.append(
                f"{slug}: classes cannot be both approved and excluded: {sorted(overlap)}"
            )

        unknown_listed = set(taxonomy_candidates) - set(mappings) - set(excluded)
        if unknown_listed:
            print("warning: unmapped classes remain for manual review:")
            for name in sorted(unknown_listed):
                print(f"- {name}")

    if errors:
        print("\nRegistry validation failed:")
        for err in errors:
            print(f"- {err}")
        return 1

    print("\nRegistry validation passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
