#!/bin/zsh
# scripts/system/detect-displays.zsh — detect display mode for layout selection
# Output: dual_display | single_external | single_builtin | safe_layout

set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"

/usr/bin/python3 - <<'PY'
import json, subprocess, sys

def main():
    try:
        raw = subprocess.check_output(
            ["system_profiler", "SPDisplaysDataType", "-json"],
            text=True,
            timeout=15,
        )
        data = json.loads(raw)
    except Exception as exc:
        print("safe_layout")
        print(f"# detect error: {exc}", file=sys.stderr)
        return

    displays = []
    for gpu in data.get("SPDisplaysDataType", []):
        for disp in gpu.get("spdisplays_ndrvs", []):
            if disp.get("_spdisplays_displayport") == "spdisplays_disconnected":
                continue
            res = disp.get("_spdisplays_pixels", "")
            w = h = 0
            if " x " in res:
                parts = res.split(" x ")
                try:
                    w, h = int(parts[0]), int(parts[1].split()[0])
                except ValueError:
                    pass
            displays.append({
                "name": disp.get("_name", "unknown"),
                "width": w,
                "height": h,
                "main": disp.get("spdisplays_main", "") == "spdisplays_yes",
            })

    online = [d for d in displays if d["width"] > 0 and d["height"] > 0]
    if not online:
        print("safe_layout")
        return

    builtin = [d for d in online if "built-in" in d["name"].lower() or "color lcd" in d["name"].lower()]
    external = [d for d in online if d not in builtin]

    ultrawide = [d for d in online if d["width"] / max(d["height"], 1) >= 2.0]

    if len(online) >= 2 and ultrawide and (builtin or len(external) >= 2):
        print("dual_display")
    elif ultrawide and len(online) == 1:
        print("single_external")
    elif len(builtin) >= 1 and not external:
        print("single_builtin")
    elif len(online) == 1:
        print("single_external" if ultrawide else "single_builtin")
    else:
        print("safe_layout")

if __name__ == "__main__":
    main()
PY
