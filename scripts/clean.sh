#!/bin/bash
set -euo pipefail

source ./scripts/utils.sh

clean_bundle() {
    local bundle_name="$1"
    local files=( $(get_brewfiles "$bundle_name") )

    echo "🧹 Cleaning '$bundle_name' bundle..."
    for file in "${files[@]}"; do
        if [[ ! -f "$file" ]]; then
            echo "❌ Brewfile '$file' not found!"
            continue
        fi
        while IFS= read -r line; do
            [[ "$line" =~ ^#.*$ ]] && continue
            [[ -z "$line" ]] && continue
            if [[ "$line" =~ brew\ \"([^\"]+)\" ]]; then
                pkg="${BASH_REMATCH[1]}"
                echo "🔻 Uninstalling $pkg..."
                brew uninstall --ignore-dependencies "$pkg" 2>/dev/null || true
            fi
        done < "$file"
    done
    echo "✅ '$bundle_name' cleaned!"
    echo
}

if [[ $# -eq 0 ]]; then
    for file in "$BUNDLES_DIR"/*.Brewfile; do
        clean_bundle "$(basename "$file" .Brewfile)"
    done
else
    for bundle_name in "$@"; do
        clean_bundle "$bundle_name"
    done
fi

echo "🎉 All requested bundles cleaned!"
exit 0
