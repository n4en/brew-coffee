#!/usr/bin/env bash
set -euo pipefail

# Resolve script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

COMMAND="${1:-help}"
shift || true

check_homebrew_and_install_if_missing() {
    if ! command -v brew &>/dev/null; then
        log_warn "Homebrew not found. Attempting to install Homebrew (interactive)..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Attempt to eval brew environment for Apple Silicon & Intel
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "\$('/opt/homebrew/bin/brew' shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "\$('/usr/local/bin/brew' shellenv)"
        fi
        if ! command -v brew &>/dev/null; then
            log_error "Homebrew installation failed or brew not in PATH. Please add brew to PATH and retry."
            exit 1
        fi
        log_success "Homebrew installed and available."
    fi
}

show_help() {
    cat <<EOF
☕ brew-coffee — developer environment setup made easy

Usage:
  brew-coffee <command> [bundle-name]

Commands:
  install [bundle]   Install a specific bundle or all when omitted
  list               List all available bundles
  check [bundle|all] Check if bundles' packages are installed
  clean [bundle]     Uninstall packages from a bundle
  help               Show this help

Examples:
  brew-coffee install nodejs
  brew-coffee check all
  brew-coffee list
EOF
}

# Ensure brew exists before any operation except 'help' and 'list'
case "$COMMAND" in
    help|--help|-h|list)
        # list doesn't require brew
        ;;
    *)
        check_homebrew_and_install_if_missing
        ;;
esac

case "$COMMAND" in
    install)
        "$SCRIPT_DIR/scripts/install.sh" "$@"
        "$SCRIPT_DIR/scripts/plugins.sh" install
        ;;
    clean)
        "$SCRIPT_DIR/scripts/clean.sh" "$@"
        "$SCRIPT_DIR/scripts/plugins.sh" clean
        ;;
    list)
        "$SCRIPT_DIR/scripts/list.sh" "$@"
        ;;
    check)
        "$SCRIPT_DIR/scripts/check.sh" "$@"
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        log_error "Unknown command: $COMMAND"
        show_help
        exit 1
        ;;
esac
