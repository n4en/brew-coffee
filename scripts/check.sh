#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# shellcheck disable=SC2329
check_bundle() {
    local bundle_name="$1"
    IFS=' ' read -r -a files <<< "$(get_brewfiles "$bundle_name")"

    log_info "Checking bundle: $bundle_name"
    for file in "${files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "Brewfile not found: $file"
            return 1
        fi

        if brew bundle check --file="$file"; then
            log_success "All packages from $file are present."
        else
            log_warn "Packages missing for $file"
        fi
    done
}

iterate_bundles "check_bundle" "$@"
exit 0
