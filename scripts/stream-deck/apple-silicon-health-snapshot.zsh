#!/bin/zsh
# Read-only 30-second Apple Silicon thermal and power snapshot.

set -euo pipefail

if ! command -v powermetrics >/dev/null 2>&1; then
  print -u2 "Error: powermetrics is not available on this Mac."
  exit 1
fi

print "Collecting a 30-second thermal and power snapshot..."
sudo powermetrics \
  --samplers thermal,cpu_power,gpu_power,ane_power \
  --sample-count 30 \
  --sample-rate 1000
