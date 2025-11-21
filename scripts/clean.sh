#!/bin/bash
# shellcheck disable=SC2317
set -euo pipefail

CURRENT_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$CURRENT_SCRIPT_DIR/.." && pwd)"
BUNDLES_DIR="$REPO_ROOT/bundles"
source "$REPO_ROOT/lib/common.sh"

# shellcheck disable=SC2329
uninstall_package() {
    local type="$1"
    local name="$2"
    local installed_casks="$3"
    name="$(echo "$name" | xargs)"
    case "$type" in
        brew)
            log_info "Uninstalling formula: $name"
            brew uninstall "$name" || log_warn "Failed to uninstall formula: $name"
            ;;
        cask)
            log_info "Checking if cask is installed: $name"
            if echo "$installed_casks" | grep -q "^${name}\$"; then
                log_info "Uninstalling cask: $name"
                brew uninstall --cask "$name" || log_warn "Failed to uninstall cask: $name"
            else
                log_warn "Cask not found: $name (not installed via Homebrew)"
            fi
            ;;
        mas)
            log_warn "mas entries are not auto-uninstalled. ID/Name: $name"
            ;;
        tap)
            log_info "Skipping tap removal for: $name (manual if desired)"
            ;;
        *)
            log_warn "Unknown entry type: $type"
            ;;
    esac
}

# shellcheck disable=SC2329
clean_bundle() {
    local bundle_name="$1"
    local installed_casks
    installed_casks=$(brew list --cask 2>/dev/null || true)
    
    IFS=' ' read -r -a files <<< "$(get_brewfiles "$bundle_name")"
    log_info "Cleaning bundle: $bundle_name"
    for file in "${files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_error "Brewfile not found: $file"
            continue
        fi
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ "$line" =~ ^[[:space:]]*$ ]] && continue
            if parsed=$(parse_brewfile_line "$line" 2>/dev/null); then
                IFS=':' read -r typ name <<< "$parsed"
                uninstall_package "$typ" "$name" "$installed_casks"
            fi
        done < "$file"
    done
    log_success "Bundle cleaned: $bundle_name"
}

for arg in "$@"; do
    if [[ "$arg" == "dev" ]]; then
        "$CURRENT_SCRIPT_DIR/plugins.sh" clean
        break
    fi
done

for arg in "$@"; do
    if ! validate_bundle_name "$arg"; then
        exit 1
    fi
done

iterate_bundles "clean_bundle" "$@"
log_success "All requested bundles cleaned."
exit 0
