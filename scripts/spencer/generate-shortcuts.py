#!/usr/bin/env python3
"""Generate Start My Day–style Apple Shortcut files for every Spencer desktop layout."""

from __future__ import annotations

import plistlib
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT_DIR = ROOT / "shortcuts" / "spencer"

# (layout_id, shortcut_name)
# Shortcut name = layout id (except Start My Day, which already exists under that title).
LAYOUTS = [
    ("CLEANUP", "CLEANUP"),
    ("DESKTOP_COMMANDER", "DESKTOP_COMMANDER"),
    ("NOTEBOOKLM", "NOTEBOOKLM"),
    ("PRINT_FACTORY_PRINT_Fulo_Filo", "PRINT_FACTORY_PRINT_Fulo_Filo"),
    ("START_MY_DAY", "START_MY_DAY"),
    ("THINKING_WORKSPACE", "THINKING_WORKSPACE"),
]

SHELL_TEMPLATE = """open -a Spencer
for i in {{1..20}}; do
  if /Applications/Spencer.app/Contents/MacOS/SpencerCLI --list >/dev/null 2>&1; then
    /Applications/Spencer.app/Contents/MacOS/SpencerCLI --restore "{layout}" --launch-apps=true
    exit $?
  fi
  sleep 0.5
done
echo "Spencer CLI did not become ready" >&2
exit 1
"""


def workflow_for(layout: str, name: str) -> dict:
    return {
        "WFWorkflowName": name,
        "WFWorkflowActions": [
            {
                "WFWorkflowActionIdentifier": "is.workflow.actions.runshellscript",
                "WFWorkflowActionParameters": {
                    "WFShellScript": SHELL_TEMPLATE.format(layout=layout),
                    "InputMode": "to stdin",
                    "Shell": "/bin/zsh",
                },
            },
            {
                "WFWorkflowActionIdentifier": "is.workflow.actions.output",
                "WFWorkflowActionParameters": {
                    "WFOutputContentItemName": "Shell Script Result",
                    "WFNoOutputSurfaceBehavior": "Do Nothing",
                },
            },
        ],
        "WFWorkflowClientVersion": "1300.0.0",
        "WFWorkflowClientRelease": "3.0",
        "WFWorkflowMinimumClientVersion": 900,
        "WFWorkflowMinimumClientVersionString": "900",
        "WFWorkflowIcon": {
            "WFWorkflowIconStartColor": 431817727,
            "WFWorkflowIconGlyphNumber": 59511,
        },
        "WFWorkflowTypes": [],
        "WFWorkflowInputContentItemClasses": [
            "WFAppStoreAppContentItem",
            "WFArticleContentItem",
            "WFContactContentItem",
            "WFDateContentItem",
            "WFEmailAddressContentItem",
            "WFGenericFileContentItem",
            "WFImageContentItem",
            "WFiTunesProductContentItem",
            "WFLocationContentItem",
            "WFDCMapsLinkContentItem",
            "WFAVAssetContentItem",
            "WFPDFContentItem",
            "WFPhoneNumberContentItem",
            "WFRichTextContentItem",
            "WFSafariWebPageContentItem",
            "WFStringContentItem",
            "WFURLContentItem",
        ],
        "WFWorkflowOutputContentItemClasses": [],
    }


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    # Remove older generated names so the folder only has the current set.
    for old in OUT_DIR.glob("Spencer_*.shortcut"):
        old.unlink()
    for old in OUT_DIR.glob("*.unsigned.shortcut"):
        old.unlink()

    generated: list[str] = []
    for layout, shortcut_name in LAYOUTS:
        body = SHELL_TEMPLATE.format(layout=layout)
        zsh_path = OUT_DIR / f"{layout}.zsh"
        zsh_path.write_text(body + "\n", encoding="utf-8")
        zsh_path.chmod(0o755)
        print(f"wrote {zsh_path}")

        unsigned = OUT_DIR / f"{layout}.unsigned.shortcut"
        signed = OUT_DIR / f"{layout}.shortcut"
        unsigned.write_bytes(
            plistlib.dumps(workflow_for(layout, shortcut_name), fmt=plistlib.FMT_BINARY)
        )
        subprocess.run(
            [
                "shortcuts",
                "sign",
                "-m",
                "anyone",
                "-i",
                str(unsigned),
                "-o",
                str(signed),
            ],
            check=True,
        )
        unsigned.unlink(missing_ok=True)
        generated.append(str(signed))
        print(f"wrote {signed}")

    print(f"generated {len(generated)} shortcut file(s) + matching .zsh bodies in {OUT_DIR}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
