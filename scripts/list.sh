#!/bin/bash
set -euo pipefail

source ./scripts/utils.sh

echo "📦 Available bundles:"
for file in "$BUNDLES_DIR"/*.Brewfile; do
    echo " - $(basename "$file" .Brewfile)"
done
