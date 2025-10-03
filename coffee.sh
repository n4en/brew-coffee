#!/bin/bash
set -euo pipefail

COMMAND="${1:-}"
shift || true

check_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo "⚡ Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo 'eval "$('/opt/homebrew/bin/brew' shellenv)"' >> "$HOME/.zprofile"
        eval "$('/opt/homebrew/bin/brew' shellenv)"
        echo "✅ Homebrew installed!"
    fi
}

check_homebrew

case "$COMMAND" in
    install)
        ./scripts/install.sh "$@"
        ;;
    clean)
        ./scripts/clean.sh "$@"
        ;;
    list)
        ./scripts/list.sh
        ;;
    check)
        ./scripts/check.sh "$@"
        ;;
    ""|help|-h|--help)
        echo "Usage: $0 {install|clean|list|check} [bundle_name|all]"
        exit 0
        ;;
    *)
        echo "Usage: $0 {install|clean|list|check} [bundle_name|all]"
        exit 1
        ;;
esac
