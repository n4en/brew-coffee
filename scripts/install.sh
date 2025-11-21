#!/bin/bash
set -euo pipefail

CURRENT_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$CURRENT_SCRIPT_DIR/.." && pwd)"
BUNDLES_DIR="$REPO_ROOT/bundles"
source "$REPO_ROOT/lib/common.sh"

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
    if ! validate_bundle_name "$arg"; then
        exit 1
    fi
done

# Track exit status of bundle installation
overall_status=0
iterate_bundles "install_bundle" "$@" || overall_status=$?

# Only proceed with plugins if bundles installed successfully
if [ $overall_status -eq 0 ]; then
    for arg in "$@"; do
        if [[ "$arg" == "dev" ]]; then
            "$CURRENT_SCRIPT_DIR/plugins.sh" install || overall_status=$?
            break
        fi
    done
fi

if [ $overall_status -eq 0 ]; then
    log_success "All requested bundles processed."
    exit 0
else
    log_error "Bundle installation encountered errors."
    exit 1
fi
