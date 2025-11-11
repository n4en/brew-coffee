#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

clean_bundle() {
    local bundle_name="$1"
    IFS=' ' read -r -a files <<< "$(get_brewfiles "$bundle_name")"

    log_info "Cleaning bundle: $bundle_name"
    for file in "${files[@]}"; do
        if [[ ! -f "$file" ]]; then
            log_warn "Brewfile not found: $file"
            continue
        fi

        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ "$line" =~ ^[[:space:]]*$ ]] && continue

            if parsed=$(parse_brewfile_line "$line" 2>/dev/null); then
                IFS=':' read -r typ name <<< "$parsed"
                case "$typ" in
                    brew)
                        if brew list --formula | grep -q "^${name}\$"; then
                            log_info "Uninstalling formula: $name"
                            brew uninstall --ignore-dependencies "$name" || true
                        else
                            log_info "Formula not installed: $name"
                        fi
                        ;;
                    cask)
                        if brew list --cask | grep -q "^${name}\$"; then
                            log_info "Uninstalling cask: $name"
                            brew uninstall --cask "$name" || true
                        else
                            log_info "Cask not installed: $name"
                        fi
                        ;;
                    mas)
                        log_warn "mas entries are not auto-uninstalled. ID/Name: $name"
                        ;;
                    tap)
                        log_info "Skipping tap removal for: $name (manual if desired)"
                        ;;
                    *)
                        log_warn "Unknown entry type for line: $line"
                        ;;
                esac
            else
                log_warn "Could not parse line: $line"
            fi
        done < "$file"
    done

    log_success "Bundle cleaned: $bundle_name"
}

if [[ $# -eq 0 ]]; then
    for file in "$BUNDLES_DIR"/*.Brewfile; do
        bundle_name="$(basename "$file" .Brewfile)"
        clean_bundle "$bundle_name"
    done
else
    for bundle_name in "$@"; do
        if bundle_exists "$bundle_name"; then
            clean_bundle "$bundle_name"
        else
            log_warn "Bundle '$bundle_name' does not exist; skipping."
        fi
    done
fi

log_success "All requested bundles cleaned."
exit 0
