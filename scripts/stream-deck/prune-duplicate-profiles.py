#!/usr/bin/env python3
"""Archive duplicate Stream Deck profiles, keeping only active preferred profiles."""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]
PROFILES_DIR = Path.home() / "Library/Application Support/com.elgato.StreamDeck/ProfilesV3"
PLIST = Path.home() / "Library/Preferences/com.elgato.StreamDeck.plist"
ARCHIVE_ROOT = PROJECT_ROOT / "backups" / "pruned-profiles"

DEVICE_KEYS = (
    "@(32)[2a764330-76e7-4d05-bbed-35a78a8849bd]",
    "@(0)[]",
)


def preferred_profiles() -> set[str]:
    keep: set[str] = set()
    for key in DEVICE_KEYS:
        result = subprocess.run(
            [
                "/usr/libexec/PlistBuddy",
                "-c",
                f"Print :Devices:{key}:ESDProfilesInfo:ESDProfilesPreferred",
                str(PLIST),
            ],
            capture_output=True,
            text=True,
        )
        if result.returncode == 0 and result.stdout.strip():
            keep.add(result.stdout.strip().lower())
    return keep


def main() -> int:
    keep = preferred_profiles()
    if not keep:
        print("ERROR: No preferred profiles found in Stream Deck plist.", file=sys.stderr)
        return 1

    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    ARCHIVE_ROOT.mkdir(parents=True, exist_ok=True)
    archived: list[str] = []

    for profile_dir in sorted(PROFILES_DIR.glob("*.sdProfile")):
        profile_id = profile_dir.name.replace(".sdProfile", "").lower()
        if profile_id in keep:
            continue

        manifest_path = profile_dir / "manifest.json"
        if not manifest_path.exists():
            continue

        data = json.loads(manifest_path.read_text(encoding="utf-8"))
        name = data.get("Name", "")
        if name not in ("iPad Console", "iPad Console (Surface)", "Operations Console"):
            continue

        dest = ARCHIVE_ROOT / f"{profile_dir.name}_{stamp}"
        if dest.exists():
            shutil.rmtree(dest)
        shutil.move(str(profile_dir), str(dest))
        archived.append(f"{name} ({profile_dir.name})")

    print("Keeping preferred:", ", ".join(sorted(keep)))
    if archived:
        print(f"Archived {len(archived)} duplicate profile(s):")
        for entry in archived:
            print(f"  - {entry}")
    else:
        print("No duplicate profiles to archive.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
