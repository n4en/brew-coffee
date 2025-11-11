#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$SCRIPT_DIR"

BUNDLES_DIR="$REPO_ROOT/bundles"

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
RESET="\033[0m"


log_info()    { printf "%b\n" "${BLUE}ℹ️  $*${RESET}"; }
log_success() { printf "%b\n" "${GREEN}✅ $*${RESET}"; }
log_warn()    { printf "%b\n" "${YELLOW}⚠️  $*${RESET}"; }
log_error()   { printf "%b\n" "${RED}❌ $*${RESET}" >&2; }

require_brew() {
    if ! command -v brew >/dev/null 2>&1; then
        log_error "Homebrew not found. Please install it first or run the CLI which can install Homebrew for you."
        exit 1
    fi
}

get_brewfiles() {
    local bundle_name="$1"
    local main_file="$BUNDLES_DIR/${bundle_name}.Brewfile"
    local files="$main_file"

    case "$bundle_name" in
        aws|azure|gcp|k8s)
            files="$files $BUNDLES_DIR/infra.Brewfile"
            ;;
    esac

    echo "$files"
}

bundle_exists() {
    local bundle_name="$1"
    local main_file="$BUNDLES_DIR/${bundle_name}.Brewfile"
    [ -f "$main_file" ]
}

iterate_bundles() {
    local action_func="$1"
    shift
    local bundles=("$@")

    if [[ ${#bundles[@]} -eq 0 ]]; then
        # Process all bundles
        for file in "$BUNDLES_DIR"/*.Brewfile; do
            [ -e "$file" ] || continue
            local bundle_name
            bundle_name="$(basename "$file" .Brewfile)"
            "$action_func" "$bundle_name"
        done
    else
        # Process specified bundles
        for bundle_name in "${bundles[@]}"; do
            if bundle_exists "$bundle_name"; then
                "$action_func" "$bundle_name"
            else
                log_warn "Bundle '$bundle_name' does not exist; skipping."
            fi
        done
    fi
}

_extract_package_name() {
    local line="$1"
    echo "$line" | sed -n 's/^[a-z]*[[:space:]]*"\(.*\)"/\1/p'
}

parse_brewfile_line() {
    local line="$1"
    line="${line%"${line##*[![:space:]]}"}"
    line="${line#"${line%%[![:space:]]*}"}"

    case "$line" in
        \#*|"") return 1 ;;
    esac

    local pkg
    local type=""

    if echo "$line" | grep -q '^brew[[:space:]]*".*"$'; then
        type="brew"
    elif echo "$line" | grep -q '^cask[[:space:]]*".*"$'; then
        type="cask"
    elif echo "$line" | grep -q '^mas[[:space:]]*".*"$'; then
        type="mas"
    elif echo "$line" | grep -q '^tap[[:space:]]*".*"$'; then
        type="tap"
    else
        return 2
    fi

    pkg=$(_extract_package_name "$line")
    printf "%s:%s" "$type" "$pkg"
    return 0
}
