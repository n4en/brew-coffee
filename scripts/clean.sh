#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

# shellcheck disable=SC2329
uninstall_package() {
    local type="$1"
    local name="$2"
    name="$(echo "$name" | xargs)"

    case "$type" in
        brew)
            log_info "Uninstalling formula: $name"
            brew uninstall --ignore-dependencies "$name" || log_warn "Failed to uninstall formula: $name"
            ;;
        cask)
            log_info "Uninstalling cask: $name"
            brew uninstall --cask "$name" || log_warn "Failed to uninstall cask: $name"
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
                uninstall_package "$typ" "$name"
            fi
        done < "$file"
    done

    log_success "Bundle cleaned: $bundle_name"
}

for arg in "$@"; do
    if [[ "$arg" == "dev" ]]; then
        "$SCRIPT_DIR/plugins.sh" clean
        break
    fi
done

iterate_bundles "clean_bundle" "$@"
exit 0
