#!/usr/bin/env python3
"""
Sync disease catalogs in Spring and Mobile from one canonical JSON file.

Usage:
  python scripts/sync_disease_catalogs.py --check
  python scripts/sync_disease_catalogs.py --write
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CATALOG_JSON = ROOT / "data" / "disease_catalog.json"
JAVA_FILE = ROOT / "spring-api" / "src" / "main" / "java" / "com" / "rice" / "disease" / "service" / "DiseaseInfoCatalog.java"
DART_FILE = ROOT / "mobile" / "lib" / "features" / "result" / "controllers" / "disease_info_catalog.dart"

FIELD_ORDER = [
    "key",
    "label",
    "scientific_name",
    "icon",
    "severity",
    "severity_label",
    "description",
    "symptoms",
    "cause",
    "treatment",
    "prevention",
]


def _escape_java(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"')


def _escape_dart(value: str) -> str:
    return value.replace("\\", "\\\\").replace("'", "\\'")


def _render_java_map(items: dict[str, dict[str, str]], indent: str = "        ") -> str:
    lines: list[str] = ["Map.of("]
    total = len(items)
    for idx, (key, entry) in enumerate(items.items(), start=1):
        lines.append(f'{indent}"{_escape_java(key)}",')
        lines.append(f"{indent}new DiseaseInfo(")
        lines.append(f'{indent}    "{_escape_java(entry["key"])}",')
        lines.append(f'{indent}    "{_escape_java(entry["label"])}",')
        lines.append(f'{indent}    "{_escape_java(entry["scientific_name"])}",')
        lines.append(f'{indent}    "{_escape_java(entry["icon"])}",')
        lines.append(f'{indent}    "{_escape_java(entry["severity"])}",')
        lines.append(f'{indent}    "{_escape_java(entry["severity_label"])}",')
        lines.append(f'{indent}    "{_escape_java(entry["description"])}",')
        lines.append(f'{indent}    "{_escape_java(entry["symptoms"])}",')
        lines.append(f'{indent}    "{_escape_java(entry["cause"])}",')
        lines.append(f'{indent}    "{_escape_java(entry["treatment"])}",')
        lines.append(f'{indent}    "{_escape_java(entry["prevention"])}"')
        lines.append(f"{indent}){',' if idx < total else ''}")
        if idx < total:
            lines.append("")
    lines.append("    )")
    return "\n".join(lines)


def _render_dart_map(items: dict[str, dict[str, str]], indent: str = "    ") -> str:
    lines: list[str] = ["{"]
    for key, entry in items.items():
        lines.append(f"{indent}'{_escape_dart(key)}': DiseaseInfo(")
        lines.append(f"{indent}  key: '{_escape_dart(entry['key'])}',")
        lines.append(f"{indent}  label: '{_escape_dart(entry['label'])}',")
        lines.append(
            f"{indent}  scientificName: '{_escape_dart(entry['scientific_name'])}',"
        )
        lines.append(f"{indent}  icon: '{_escape_dart(entry['icon'])}',")
        lines.append(f"{indent}  severity: '{_escape_dart(entry['severity'])}',")
        lines.append(
            f"{indent}  severityLabel: '{_escape_dart(entry['severity_label'])}',"
        )
        lines.append(f"{indent}  description: '{_escape_dart(entry['description'])}',")
        lines.append(f"{indent}  symptoms: '{_escape_dart(entry['symptoms'])}',")
        lines.append(f"{indent}  cause: '{_escape_dart(entry['cause'])}',")
        lines.append(f"{indent}  treatment: '{_escape_dart(entry['treatment'])}',")
        lines.append(f"{indent}  prevention: '{_escape_dart(entry['prevention'])}',")
        lines.append(f"{indent}),")
    lines.append("  }")
    return "\n".join(lines)


def _replace_or_raise(text: str, pattern: str, replacement: str, path: Path) -> str:
    updated, count = re.subn(pattern, replacement, text, count=1, flags=re.DOTALL)
    if count != 1:
        raise RuntimeError(f"Could not find expected catalog block in {path}")
    return updated


def build_java_section(en: dict[str, dict[str, str]], km: dict[str, dict[str, str]]) -> str:
    en_map = _render_java_map(en)
    km_map = _render_java_map(km)
    return (
        "    // ──────────────────────────────────────────────────────────────────────────\n"
        "    // English\n"
        "    // ──────────────────────────────────────────────────────────────────────────\n\n"
        f"    public static final Map<String, DiseaseInfo> EN = {en_map};\n\n"
        "    // ──────────────────────────────────────────────────────────────────────────\n"
        "    // Khmer (ខ្មែរ)\n"
        "    // ──────────────────────────────────────────────────────────────────────────\n\n"
        f"    public static final Map<String, DiseaseInfo> KM = {km_map};\n\n"
        "    // ──────────────────────────────────────────────────────────────────────────\n"
        "    // Lookup helper"
    )


def build_dart_section(en: dict[str, dict[str, str]], km: dict[str, dict[str, str]]) -> str:
    en_map = _render_dart_map(en)
    km_map = _render_dart_map(km)
    return (
        f"  static const _en = {en_map};\n\n"
        f"  static const _km = {km_map};\n\n"
        "  static DiseaseInfo byClass"
    )


def sync(write: bool) -> int:
    data = json.loads(CATALOG_JSON.read_text(encoding="utf-8"))
    en: dict[str, dict[str, str]] = data["languages"]["en"]
    km: dict[str, dict[str, str]] = data["languages"]["km"]

    changed = []

    java_text = JAVA_FILE.read_text(encoding="utf-8")
    java_updated = _replace_or_raise(
        java_text,
        r"\s*// ──────────────────────────────────────────────────────────────────────────\s*// English[\s\S]*?// ──────────────────────────────────────────────────────────────────────────\s*// Lookup helper",
        build_java_section(en, km),
        JAVA_FILE,
    )
    if java_updated != java_text:
        changed.append(JAVA_FILE)
        if write:
            JAVA_FILE.write_text(java_updated, encoding="utf-8")

    dart_text = DART_FILE.read_text(encoding="utf-8")
    dart_updated = _replace_or_raise(
        dart_text,
        r"\s*static const _en = \{[\s\S]*?\n\s*\};\n\n\s*static const _km = \{[\s\S]*?\n\s*\};\n\n\s*static DiseaseInfo byClass",
        build_dart_section(en, km),
        DART_FILE,
    )
    if dart_updated != dart_text:
        changed.append(DART_FILE)
        if write:
            DART_FILE.write_text(dart_updated, encoding="utf-8")

    if write:
        if changed:
            print("Updated:")
            for path in changed:
                print(f"- {path.relative_to(ROOT)}")
        else:
            print("No changes needed.")
        return 0

    if changed:
        print("Out of sync:")
        for path in changed:
            print(f"- {path.relative_to(ROOT)}")
        return 1
    print("All catalogs are in sync.")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true")
    mode.add_argument("--write", action="store_true")
    args = parser.parse_args()
    return sync(write=args.write)


if __name__ == "__main__":
    raise SystemExit(main())
