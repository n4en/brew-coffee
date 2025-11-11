#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

check_bundle() {
    local bundle_name="$1"
    IFS=' ' read -r -a files <<< "$(get_brewfiles "$bundle_name")"

    log_info "Checking bundle: $bundle_name"
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            if brew bundle check --file="$file"; then
                log_success "All packages from $file are present."
            else
                log_warn "Packages missing for $file"
            fi
        else
            log_error "Brewfile not found: $file"
        fi
    done
}

if [[ $# -eq 0 || "${1:-}" == "all" ]]; then
    for file in "$BUNDLES_DIR"/*.Brewfile; do
        bundle_name="$(basename "$file" .Brewfile)"
        check_bundle "$bundle_name"
    done
else
    for bundle_name in "$@"; do
        if bundle_exists "$bundle_name"; then
            check_bundle "$bundle_name"
        else
            log_warn "Bundle '$bundle_name' does not exist; skipping."
        fi
    done
fi

exit 0
