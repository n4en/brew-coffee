#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

declare -i count=0
echo "📦 Available bundles:"
for file in "$BUNDLES_DIR"/*.Brewfile; do
    [ -e "$file" ] || continue
    echo " - $(basename "$file" .Brewfile)"
    ((count++))
done

echo ""
log_info "Total: $count bundle(s)"
exit 0
