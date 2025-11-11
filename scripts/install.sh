#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

install_bundle() {
    local bundle_name="$1"
    IFS=' ' read -r -a files <<< "$(get_brewfiles "$bundle_name")"

    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            log_info "Installing bundle '$bundle_name' from: $file"
            require_brew
            if brew bundle install --file="$file"; then
                log_success "Installed from $file"
            else
                log_error "Installation failed for $file"
            fi
        else
            log_error "Brewfile not found: $file"
        fi
    done
}

if [[ $# -eq 0 ]]; then
    for file in "$BUNDLES_DIR"/*.Brewfile; do
        bundle_name="$(basename "$file" .Brewfile)"
        install_bundle "$bundle_name"
    done
else
    for bundle_name in "$@"; do
        if bundle_exists "$bundle_name"; then
            install_bundle "$bundle_name"
        else
            log_warn "Bundle '$bundle_name' does not exist; skipping."
        fi
    done
fi

log_success "All requested bundles processed."
exit 0
