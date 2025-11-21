#!/bin/bash
# shellcheck disable=SC2317
set -euo pipefail

CURRENT_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$CURRENT_SCRIPT_DIR/.." && pwd)"
BUNDLES_DIR="$REPO_ROOT/bundles"
source "$REPO_ROOT/lib/common.sh"

echo "📦 Available bundles:"

bundle_list=$(find "$BUNDLES_DIR" -maxdepth 1 -name "*.Brewfile" -type f -print0 | xargs -0 basename -a -s .Brewfile | sort)

if [ -z "$bundle_list" ]; then
    log_warn "No bundles found"
    exit 0
fi

echo "$bundle_list" | while IFS= read -r bundle; do
    echo " - $bundle"
done

count=$(echo "$bundle_list" | wc -l)
echo ""
log_info "Total: $count bundle(s)"
exit 0
