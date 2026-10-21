#!/usr/bin/env python3
"""Assign persistent content IDs once; export the CMS allowlist. No dependencies."""
import argparse
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
catalog_path = root / "chatty-pal/Resources/german-lessons.json"
manifest_path = root.parent / "chatty-pal-cms/src/api/learning-progress/catalog.json"
parser = argparse.ArgumentParser()
parser.add_argument("--check", action="store_true")
args = parser.parse_args()
catalog = json.loads(catalog_path.read_text())
changed = False
lessons = {}
for lesson in catalog["lessons"]:
    assert lesson["id"] not in lessons, "Duplicate lesson ID"
    ids = []
    for phrase in lesson["phrases"]:
        if "id" not in phrase:
            assert not args.check, "Missing persistent phrase ID"
            phrase["id"] = "p-" + hashlib.sha256(phrase["text"].encode()).hexdigest()[:16]
            changed = True
        assert phrase["id"] not in ids, "Duplicate phrase ID in lesson"
        ids.append(phrase["id"])
    assert ids, "Lessons must have required shadowing phrases"
    lessons[lesson["id"]] = ids
manifest = {"catalogRevision": "de-2026-10-v1", "lessons": lessons}
if args.check:
    assert json.loads(manifest_path.read_text()) == manifest, "CMS manifest differs from mobile catalog"
else:
    if changed:
        catalog_path.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + "\n")
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")
print(f"Learning progress catalog: {len(lessons)} lessons validated")
