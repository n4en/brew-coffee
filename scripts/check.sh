#!/bin/bash

source ./scripts/utils.sh

check_bundle() {
    local bundle_name="$1"
    local files=($(get_brewfiles "$bundle_name"))

    echo "🔍 Checking '$bundle_name' bundle..."
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            brew bundle check --file="$file"
        else
            echo "❌ Brewfile '$file' not found!"
        fi
    done
    echo
}

if [ $# -eq 0 ] || [ "$1" == "all" ]; then
    for file in "$BUNDLES_DIR"/*.Brewfile; do
        check_bundle "$(basename "$file" .Brewfile)"
    done
else
    for bundle_name in "$@"; do
        check_bundle "$bundle_name"
    done
fi
