#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

COMMAND="${1:-help}"
shift || true

ensure_readline_installed() {
    if ! brew list --formula | grep -q '^readline$'; then
        log_warn "readline not found. Installing readline via Homebrew..."
        brew install readline
        log_success "readline installed."
    fi
}

check_homebrew_and_install_if_missing() {
    if command -v brew &>/dev/null; then
        return 0
    fi

    log_warn "Homebrew not found. Attempting to install Homebrew (interactive)..."
    
    if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        log_error "Homebrew installation failed."
        exit 1
    fi

    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$('/opt/homebrew/bin/brew' shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$('/usr/local/bin/brew' shellenv)"
    fi

    if ! command -v brew &>/dev/null; then
        log_error "Homebrew installation succeeded but 'brew' not found in PATH. Please add Homebrew to your PATH manually."
        exit 1
    fi

    log_success "Homebrew installed and available."
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

case "$COMMAND" in
    help|--help|-h|list)
        ;;
    *)
        check_homebrew_and_install_if_missing
        ensure_readline_installed
        ;;
esac

case "$COMMAND" in
    install)
        "$SCRIPT_DIR/scripts/install.sh" "$@"
        ;;
    clean)
        "$SCRIPT_DIR/scripts/clean.sh" "$@"
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
