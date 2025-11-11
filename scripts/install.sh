#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# shellcheck disable=SC2329
install_bundle() {
    local bundle_name="$1"
    IFS=' ' read -r -a files <<< "$(get_brewfiles "$bundle_name")"

    for file in "${files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "Brewfile not found: $file"
            return 1
        fi

        log_info "Installing bundle '$bundle_name' from: $file"
        require_brew
        
        if brew bundle install --file="$file"; then
            log_success "Installed from $file"
        else
            log_error "Installation failed for $file"
            return 1
        fi
    done
}

for arg in "$@"; do
    if [[ "$arg" == "dev" ]]; then
        "$SCRIPT_DIR/plugins.sh" install
        break
    fi
done

iterate_bundles "install_bundle" "$@"
log_success "All requested bundles processed."
exit 0
