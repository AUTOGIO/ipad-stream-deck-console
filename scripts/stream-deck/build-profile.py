#!/usr/bin/env python3
"""Build Stream Deck profiles (iPad Console + Operations Console)."""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
import uuid
from datetime import datetime
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]
SD_SUPPORT = Path.home() / "Library/Application Support/com.elgato.StreamDeck"
PROFILES_DIR = SD_SUPPORT / "ProfilesV3"

PHYSICAL_DEVICE = "@(0)[]"
MOBILE_DEVICE = "@(32)[2a764330-76e7-4d05-bbed-35a78a8849bd]"
IPAD_SURFACE_DEVICE = "@(0)[]"

FONT_SIZE = 10
TITLE_COLOR = "#ffffff"
TITLE_ALIGN = "bottom"


def quote_open_path(path: str) -> str:
    escaped = path.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def make_open_action(path: str, title: str) -> dict:
    return {
        "ActionID": str(uuid.uuid4()),
        "LinkedTitle": False,
        "Name": "Open",
        "Plugin": {
            "Name": "Open",
            "UUID": "com.elgato.streamdeck.system.open",
            "Version": "1.0",
        },
        "Settings": {"path": quote_open_path(path)},
        "State": 0,
        "States": [
            {
                "Title": title,
                "FontSize": FONT_SIZE,
                "FontFamily": "",
                "FontStyle": "",
                "FontUnderline": False,
                "OutlineThickness": 2,
                "TitleAlignment": TITLE_ALIGN,
                "TitleColor": TITLE_COLOR,
                "ShowTitle": True,
            }
        ],
        "UUID": "com.elgato.streamdeck.system.open",
    }


def make_folder_action(page_uuid: str, title: str) -> dict:
    return {
        "ActionID": str(uuid.uuid4()),
        "LinkedTitle": False,
        "Name": "Create Folder",
        "Plugin": {
            "Name": "Create Folder",
            "UUID": "com.elgato.streamdeck.profile.openchild",
            "Version": "1.0",
        },
        "Settings": {"ProfileUUID": page_uuid},
        "State": 0,
        "States": [
            {
                "Title": title,
                "FontSize": FONT_SIZE,
                "FontFamily": "",
                "FontStyle": "",
                "FontUnderline": False,
                "OutlineThickness": 2,
                "TitleAlignment": TITLE_ALIGN,
                "TitleColor": TITLE_COLOR,
                "ShowTitle": True,
            }
        ],
        "UUID": "com.elgato.streamdeck.profile.openchild",
    }


def make_back_action() -> dict:
    return {
        "ActionID": str(uuid.uuid4()),
        "LinkedTitle": True,
        "Name": "Parent Folder",
        "Plugin": {
            "Name": "Open Parent Folder",
            "UUID": "com.elgato.streamdeck.profile.backtoparent",
            "Version": "1.0",
        },
        "Resources": None,
        "Settings": {},
        "State": 0,
        "States": [{}],
        "UUID": "com.elgato.streamdeck.profile.backtoparent",
    }


def make_ipad_folder_page(name: str, buttons: list[tuple[str, dict]]) -> tuple[str, dict]:
    """Lay out iPad folder actions with Back fixed at 0,0 (Stream Deck Mobile requirement)."""
    actions: dict[str, dict] = {"0,0": make_back_action()}
    for idx, (label, action) in enumerate(buttons):
        col = (idx % 4) + 1
        row = idx // 4
        actions[f"{col},{row}"] = action
    return make_page(name, actions, add_back=False)


def write_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(data, indent=2), encoding="utf-8")
    tmp.replace(path)


def make_page(name: str, actions: dict[str, dict], *, add_back: bool = False, back_pos: str = "4,2") -> tuple[str, dict]:
    page_uuid = str(uuid.uuid4())
    page_actions = dict(actions)
    if add_back:
        page_actions[back_pos] = make_back_action()
    manifest = {
        "Controllers": [{"Actions": page_actions or None, "Type": "Keypad"}],
        "Icon": "",
        "Name": name,
    }
    return page_uuid, manifest


def script_path(rel: str) -> str:
    return str(PROJECT_ROOT / rel)


GENERATED_COMMANDS_DIR = PROJECT_ROOT / "stream-deck/generated/commands"


def load_json_config(name: str) -> dict:
    return json.loads((PROJECT_ROOT / "config" / name).read_text(encoding="utf-8"))


def sanitize_filename(value: str) -> str:
    return "".join(ch if ch.isalnum() or ch in "-_" else "-" for ch in value).strip("-") or "action"


def ensure_command_launcher(script_rel: str, args: list[str] | None = None) -> str:
    """Wrap a zsh script in a .command file so Stream Deck Open executes it."""
    args = args or []
    GENERATED_COMMANDS_DIR.mkdir(parents=True, exist_ok=True)
    slug = sanitize_filename(f"{Path(script_rel).stem}-{'-'.join(args)}")
    launcher = GENERATED_COMMANDS_DIR / f"{slug}.command"
    quoted_args = " ".join(f'"{arg}"' for arg in args)
    body = (
        "#!/bin/zsh\n"
        "export SD_SKIP_DIALOGS=1\n"
        f'exec /bin/zsh "{script_path(script_rel)}" {quoted_args}\n'
    )
    if launcher.exists():
        if launcher.read_text(encoding="utf-8") != body:
            launcher.write_text(body, encoding="utf-8")
    else:
        launcher.write_text(body, encoding="utf-8")
    launcher.chmod(0o755)
    return str(launcher)


def cmd(script_rel: str) -> str:
    return ensure_command_launcher(script_rel)


def resolve_button_path(btn: dict, folder_pages: dict[str, tuple[str, dict]]) -> str:
    if "url" in btn:
        return btn["url"]
    if "hammerspoon" in btn:
        return f"hammerspoon://operations?action={btn['hammerspoon']}"
    if "guide" in btn:
        return f"hammerspoon://guide?action={btn['guide']}"
    if "path" in btn:
        return btn["path"]
    if "applescript" in btn:
        return script_path(btn["applescript"])
    if "app_key" in btn:
        return ensure_command_launcher("scripts/launch/open-app-key.zsh", [btn["app_key"]])
    if "path_key" in btn:
        return ensure_command_launcher("scripts/launch/open-config-path.zsh", [btn["path_key"]])
    if "folder" in btn:
        folder_uuid, _ = folder_pages[btn["folder"]]
        raise ValueError("folder buttons must be handled separately")
    if "script" in btn:
        args = [str(a) for a in (btn.get("args") or [])]
        return ensure_command_launcher(btn["script"], args)
    raise ValueError(f"Unsupported button definition: {btn}")


def stop_stream_deck() -> None:
    subprocess.run(
        ["osascript", "-e", 'tell application "Elgato Stream Deck" to quit'],
        check=False,
    )
    for _ in range(20):
        result = subprocess.run(
            ["pgrep", "-f", "/Applications/Elgato Stream Deck.app/Contents/MacOS/Stream Deck"],
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            return
        subprocess.run(["sleep", "0.5"], check=False)


def start_stream_deck() -> None:
    subprocess.run(["open", "-a", "/Applications/Elgato Stream Deck.app"], check=False)


def set_preferred_profile(device_key: str, profile_uuid: str) -> None:
    plist = str(Path.home() / "Library/Preferences/com.elgato.StreamDeck.plist")
    subprocess.run(
        [
            "/usr/libexec/PlistBuddy",
            "-c",
            f"Set Devices:{device_key}:ESDProfilesInfo:ESDProfilesPreferred {profile_uuid.lower()}",
            plist,
        ],
        check=False,
    )


def archive_existing_profiles(name: str, device_uuid: str) -> list[str]:
    """Archive prior profiles with the same name + device binding (prevents duplicate menu entries)."""
    archived: list[str] = []
    archive_root = PROJECT_ROOT / "backups" / "pruned-profiles"
    archive_root.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    for profile_dir in sorted(PROFILES_DIR.glob("*.sdProfile")):
        manifest_path = profile_dir / "manifest.json"
        if not manifest_path.exists():
            continue
        try:
            data = json.loads(manifest_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            continue
        if data.get("Name") != name:
            continue
        if data.get("Device", {}).get("UUID") != device_uuid:
            continue
        dest = archive_root / f"{profile_dir.name}_{stamp}"
        if dest.exists():
            shutil.rmtree(dest)
        shutil.move(str(profile_dir), str(dest))
        archived.append(profile_dir.name)
    return archived


def write_profile(name: str, device_uuid: str, device_model: str, main_uuid: str, main_manifest: dict, pages: list[tuple[str, dict]], preferred_device: str | None) -> dict:
    removed = archive_existing_profiles(name, device_uuid)
    if removed:
        print(f"Archived {len(removed)} old profile(s) for {name} on {device_uuid}")

    profile_uuid = str(uuid.uuid4())
    profile_id = profile_uuid.upper()
    profile_dir = PROFILES_DIR / f"{profile_id}.sdProfile"
    pages_dir = profile_dir / "Profiles"

    if profile_dir.exists():
        backup = PROJECT_ROOT / "backups" / f"profile-{name.replace(' ', '-').lower()}_{profile_id}.bak"
        backup.parent.mkdir(parents=True, exist_ok=True)
        shutil.copytree(profile_dir, backup, dirs_exist_ok=True)

    profile_manifest = {
        "Device": {"Model": device_model, "UUID": device_uuid},
        "Name": name,
        "Pages": {
            "Current": main_uuid.lower(),
            "Default": main_uuid.lower(),
            "Pages": [main_uuid.lower()],
        },
        "Version": "3.0",
    }

    profile_dir.mkdir(parents=True, exist_ok=True)
    pages_dir.mkdir(parents=True, exist_ok=True)

    main_dir = pages_dir / main_uuid.upper()
    main_dir.mkdir(parents=True, exist_ok=True)
    (main_dir / "Images").mkdir(exist_ok=True)
    write_json(main_dir / "manifest.json", main_manifest)

    for page_uuid, page_manifest in pages:
        page_dir = pages_dir / page_uuid.upper()
        page_dir.mkdir(parents=True, exist_ok=True)
        (page_dir / "Images").mkdir(exist_ok=True)
        write_json(page_dir / "manifest.json", page_manifest)
        profile_manifest["Pages"]["Pages"].append(page_uuid.lower())

    profile_manifest["Pages"]["Current"] = main_uuid.lower()
    profile_manifest["Pages"]["Default"] = main_uuid.lower()
    write_json(profile_dir / "manifest.json", profile_manifest)

    if preferred_device:
        set_preferred_profile(preferred_device, profile_uuid)

    return {
        "profile_name": name,
        "profile_uuid": profile_uuid.lower(),
        "profile_dir": str(profile_dir),
        "main_page": main_uuid.lower(),
        "page_count": len(profile_manifest["Pages"]["Pages"]),
    }


def build_ipad_layout() -> tuple[str, dict, list[tuple[str, dict]]]:
    pages: list[tuple[str, dict, bool]] = []

    ai_uuid, ai_manifest = make_ipad_folder_page(
        "AI",
        [
            ("ChatGPT", make_open_action(cmd("scripts/launch/open-chatgpt.zsh"), "ChatGPT")),
            ("Claude", make_open_action(cmd("scripts/launch/open-claude-code.zsh"), "Claude")),
            ("Cursor", make_open_action(cmd("scripts/launch/open-cursor.zsh"), "Cursor")),
            ("Codex", make_open_action(cmd("scripts/launch/open-codex.zsh"), "Codex")),
            ("Notes", make_open_action(cmd("scripts/launch/open-notes.zsh"), "Notes")),
        ],
    )
    pages.append(("ai", ai_uuid, ai_manifest, True))

    macos_uuid, macos_manifest = make_ipad_folder_page(
        "macOS",
        [
            ("Terminal", make_open_action(cmd("scripts/launch/open-terminal.zsh"), "Terminal")),
            ("Home", make_open_action(str(Path.home()), "Home")),
            ("Health", make_open_action(cmd("scripts/system/health-check.zsh"), "Health")),
            ("Activity", make_open_action("/System/Applications/Utilities/Activity Monitor.app", "Activity")),
            ("AW", make_open_action(cmd("scripts/launch/open-activitywatch.zsh"), "AW")),
        ],
    )
    pages.append(("macos", macos_uuid, macos_manifest, True))

    projects_uuid, projects_manifest = make_ipad_folder_page(
        "Projects",
        [
            ("GitHub", make_open_action(str(Path.home() / "Documents/GitHub"), "GitHub")),
            ("Pick", make_open_action(script_path("applescript/project-selector.applescript"), "Pick")),
        ],
    )
    pages.append(("projects", projects_uuid, projects_manifest, True))

    audio_uuid, audio_manifest = make_ipad_folder_page("Audio", [])
    pages.append(("audio", audio_uuid, audio_manifest, True))

    workspace_uuid, workspace_manifest = make_ipad_folder_page(
        "Workspace",
        [
            ("Start Day", make_open_action(cmd("scripts/workspace/start-my-day.zsh"), "Start Day")),
            ("AI Eng", make_open_action(cmd("scripts/workspace/ai-engineering.zsh"), "AI Eng")),
            ("Dev", make_open_action(cmd("scripts/workspace/development-workspace.zsh"), "Dev")),
            ("Reset", make_open_action(cmd("scripts/workspace/reset-daily-layout.zsh"), "Reset")),
            ("Finance", make_open_action(cmd("scripts/workspace/finance.zsh"), "Finance")),
        ],
    )
    pages.append(("workspace", workspace_uuid, workspace_manifest, True))

    layouts_uuid, layouts_manifest = make_ipad_folder_page(
        "Layouts",
        [
            ("Cleanup", make_open_action(ensure_command_launcher("scripts/spencer/run-layout-shortcut.zsh", ["CLEANUP"]), "Cleanup")),
            ("Commander", make_open_action(ensure_command_launcher("scripts/spencer/run-layout-shortcut.zsh", ["DESKTOP_COMMANDER"]), "Commander")),
            ("NotebookLM", make_open_action(ensure_command_launcher("scripts/spencer/run-layout-shortcut.zsh", ["NOTEBOOKLM"]), "NotebookLM")),
            ("Fulo Filo", make_open_action(ensure_command_launcher("scripts/spencer/run-layout-shortcut.zsh", ["PRINT_FACTORY_PRINT_Fulo_Filo"]), "Fulo Filo")),
            ("Start Day", make_open_action(ensure_command_launcher("scripts/spencer/run-layout-shortcut.zsh", ["START_MY_DAY"]), "Start Day")),
            ("Thinking", make_open_action(ensure_command_launcher("scripts/spencer/run-layout-shortcut.zsh", ["THINKING_WORKSPACE"]), "Thinking")),
        ],
    )
    pages.append(("layouts", layouts_uuid, layouts_manifest, True))

    main_uuid, main_manifest = make_page(
        "Main",
        {
            "0,0": make_folder_action(ai_uuid, "AI"),
            "1,0": make_folder_action(macos_uuid, "macOS"),
            "2,0": make_folder_action(projects_uuid, "Projects"),
            "3,0": make_folder_action(audio_uuid, "Audio"),
            "4,0": make_folder_action(workspace_uuid, "Workspace"),
            "1,1": make_folder_action(layouts_uuid, "Layouts"),
            "0,1": make_open_action(cmd("scripts/system/collect-diagnostics.zsh"), "Diag"),
        },
        add_back=False,
    )

    return main_uuid, main_manifest, [(u, m) for _, u, m, _ in pages]


def build_ipad_profile() -> list[dict]:
    targets = [
        ("iPad Console", MOBILE_DEVICE, "20GAA9901", MOBILE_DEVICE),
        ("iPad Console (Surface)", IPAD_SURFACE_DEVICE, "20GAT9902", IPAD_SURFACE_DEVICE),
    ]
    results: list[dict] = []
    for name, device_uuid, device_model, preferred_device in targets:
        main_uuid, main_manifest, extra_pages = build_ipad_layout()
        results.append(
            write_profile(
                name,
                device_uuid,
                device_model,
                main_uuid,
                main_manifest,
                extra_pages,
                preferred_device,
            )
        )
    return results


def build_flat_pages_from_config(config: dict) -> tuple[str, dict, list[tuple[str, dict]]]:
    """Build swipeable flat pages (no folders) from profiles-ipad-work style JSON."""
    pages_cfg = config.get("pages") or []
    if not pages_cfg:
        raise ValueError("profiles config missing pages[]")

    built: list[tuple[str, dict]] = []
    for page in pages_cfg:
        actions: dict[str, dict] = {}
        for btn in page.get("buttons", []):
            col = int(btn["col"])
            row = int(btn["row"])
            pos = f"{col},{row}"
            label = btn.get("label", "")
            target = resolve_button_path(btn, {})
            actions[pos] = make_open_action(target, label)
        page_uuid, manifest = make_page(page.get("name", "Page"), actions, add_back=False)
        built.append((page_uuid, manifest))

    main_uuid, main_manifest = built[0]
    extra = built[1:]
    return main_uuid, main_manifest, extra


def build_ipad_work_profile() -> list[dict]:
    """New Stream Deck Mobile profile: iPad Work Console (8×4 × 2 pages)."""
    config = load_json_config("profiles-ipad-work.json")
    profile_name = config.get("profile_name", "iPad Work Console")
    main_uuid, main_manifest, extra_pages = build_flat_pages_from_config(config)
    return [
        write_profile(
            profile_name,
            MOBILE_DEVICE,
            "20GAA9901",
            main_uuid,
            main_manifest,
            extra_pages,
            MOBILE_DEVICE,
        )
    ]


def build_folder_page(
    folder_id: str,
    folder_cfg: dict,
    folder_pages: dict[str, tuple[str, dict]],
) -> tuple[str, dict]:
    actions: dict[str, dict] = {}
    buttons = folder_cfg.get("buttons", [])
    for idx, btn in enumerate(buttons[:8]):
        col = idx % 8
        row = idx // 8
        pos = f"{col},{row}"
        label = btn.get("label", folder_id)
        if "folder" in btn:
            child_uuid, _ = folder_pages[btn["folder"]]
            actions[pos] = make_folder_action(child_uuid, label)
        else:
            target = resolve_button_path(btn, folder_pages)
            actions[pos] = make_open_action(target, label)
    page_uuid, manifest = make_page(
        folder_cfg.get("name", folder_id),
        actions,
        add_back=True,
        back_pos="7,0",
    )
    return page_uuid, manifest


def build_physical_profile() -> dict:
    physical_config = load_json_config("profiles-physical.json")
    folders_cfg: dict = physical_config.get("folders", {})
    folder_pages: dict[str, tuple[str, dict]] = {}

    # Build leaf folders first (e.g. audio) so parents can reference them.
    pending = set(folders_cfg.keys())
    while pending:
        progressed = False
        for folder_id in list(pending):
            folder_cfg = folders_cfg[folder_id]
            child_refs = [
                btn["folder"]
                for btn in folder_cfg.get("buttons", [])
                if "folder" in btn
            ]
            if any(child not in folder_pages for child in child_refs):
                continue
            folder_pages[folder_id] = build_folder_page(folder_id, folder_cfg, folder_pages)
            pending.remove(folder_id)
            progressed = True
        if not progressed:
            raise RuntimeError(f"Unresolved folder dependencies: {sorted(pending)}")

    main_actions: dict[str, dict] = {}
    for btn in physical_config["home_page"]:
        pos = f"{btn['col']},{btn['row']}"
        label = btn.get("label", "").replace("\n", " ")
        if "folder" in btn:
            folder_uuid, _ = folder_pages[btn["folder"]]
            main_actions[pos] = make_folder_action(folder_uuid, label)
        elif "script" in btn:
            main_actions[pos] = make_open_action(
                ensure_command_launcher(btn["script"]),
                btn["label"],
            )
        else:
            target = resolve_button_path(btn, folder_pages)
            main_actions[pos] = make_open_action(target, label)

    main_uuid, main_manifest = make_page("Main", main_actions, add_back=False)
    extra_pages = list(folder_pages.values())
    return write_profile(
        "Operations Console",
        PHYSICAL_DEVICE,
        "20GAT9902",
        main_uuid,
        main_manifest,
        extra_pages,
        PHYSICAL_DEVICE,
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Build Stream Deck profiles")
    parser.add_argument(
        "--profile",
        choices=["mobile", "physical", "ipad-work", "all"],
        default="all",
        help="Which profile to build",
    )
    parser.add_argument("--no-restart", action="store_true", help="Do not stop/start Stream Deck")
    args = parser.parse_args()

    if not PROFILES_DIR.exists():
        print(f"ERROR: ProfilesV3 not found at {PROFILES_DIR}", file=sys.stderr)
        return 1

    if not args.no_restart:
        print("Stopping Stream Deck...")
        stop_stream_deck()

    results = []
    if args.profile in ("ipad-work", "all"):
        print("Building iPad Work Console profile...")
        results.extend(build_ipad_work_profile())
    if args.profile in ("mobile", "all"):
        print("Building iPad Console profile(s)...")
        results.extend(build_ipad_profile())
    if args.profile in ("physical", "all"):
        print("Building Operations Console profile...")
        results.append(build_physical_profile())

    print(json.dumps(results, indent=2))

    export_dir = PROJECT_ROOT / "stream-deck/profiles"
    export_dir.mkdir(parents=True, exist_ok=True)
    (export_dir / "last-build.json").write_text(json.dumps(results, indent=2), encoding="utf-8")

    if not args.no_restart:
        print("Starting Stream Deck...")
        start_stream_deck()
    print("Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
