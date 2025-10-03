#!/bin/bash
set -euo pipefail

source ./scripts/utils.sh

install_bundle() {
    local bundle_name="$1"
    local files=( $(get_brewfiles "$bundle_name") )

    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            echo "☕ Installing '$bundle_name' from $file..."
            brew bundle install --file="$file"
        else
            echo "❌ Brewfile '$file' not found!"
        fi
    done
    echo "✅ '$bundle_name' installation complete!"
    echo
}

if [[ $# -eq 0 ]]; then
    for file in "$BUNDLES_DIR"/*.Brewfile; do
        install_bundle "$(basename "$file" .Brewfile)"
    done
else
    for bundle_name in "$@"; do
        install_bundle "$bundle_name"
    done
fi

echo "🎉 All requested bundles installed!"
exit 0
