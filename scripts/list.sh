#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

echo "📦 Available bundles:"
for file in "$BUNDLES_DIR"/*.Brewfile; do
    echo " - $(basename "$file" .Brewfile)"
done

exit 0