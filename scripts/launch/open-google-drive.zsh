#!/bin/zsh
set -euo pipefail
source "$(cd "$(dirname "$0")/../lib" && pwd)/common.zsh"
sd_init_from_script "${(%):-%x}"
exec /bin/zsh "${SD_ROOT}/scripts/launch/open-url.zsh" "https://drive.google.com"
