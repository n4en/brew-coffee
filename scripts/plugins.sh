#!/bin/bash
set -euo pipefail

PLUGINS_DIR="./plugins"

if [ "$(uname -s)" = "Darwin" ]; then
    OS_TYPE="macos"
elif [ "$(uname -s)" = "Linux" ]; then
    OS_TYPE="linux"
elif [ -n "${WINDIR:-}" ]; then
    OS_TYPE="windows"
else
    OS_TYPE="unknown"
fi

find_vscode_cli() {
    local vscode_cli=""

    if command -v code >/dev/null 2>&1; then
        vscode_cli="$(command -v code)"
    else
        case "$OS_TYPE" in
            macos)
                if [ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]; then
                    vscode_cli="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
                fi
                ;;
            linux)
                for path in \
                    "$HOME/.local/share/code/bin/code" \
                    "/usr/share/code/bin/code" \
                    "/usr/local/bin/code" \
                    "/snap/bin/code" \
                    "/var/lib/flatpak/exports/bin/code"; do
                    if [ -x "$path" ]; then
                        vscode_cli="$path"
                        break
                    fi
                done
                ;;
            windows)
                for path in \
                    "$LOCALAPPDATA/Programs/Microsoft VS Code/bin/code" \
                    "$PROGRAMFILES/Microsoft VS Code/bin/code.cmd" \
                    "$PROGRAMFILES (x86)/Microsoft VS Code/bin/code.cmd"; do
                    if [ -x "$path" ]; then
                        vscode_cli="$path"
                        break
                    fi
                done
                ;;
        esac
    fi

    echo "$vscode_cli"
}

process_plugin_file() {
    local tool="$1"
    local action="$2"
    local file="$PLUGINS_DIR/$tool.txt"
    
    [ ! -f "$file" ] && return 0

    local vscode_cli
    vscode_cli="$(find_vscode_cli)"

    case "$action" in
        install)
            echo "☕ Installing $tool plugins..."
            ;;
        uninstall)
            echo "🧹 Uninstalling $tool plugins..."
            ;;
    esac

    while IFS= read -r plugin || [ -n "$plugin" ]; do
        plugin=$(echo "$plugin" | tr -d '[:space:]')

        case "$plugin" in
            ""|\#*)
                continue
                ;;
        esac

        case "$tool" in
            vscode)
                if [ -z "$vscode_cli" ]; then
                    echo "⚠️  VSCode CLI not found"
                    return 1
                fi

                case "$action" in
                    install)
                        if "$vscode_cli" --list-extensions 2>/dev/null | grep -i "^${plugin}$" > /dev/null 2>&1; then
                            echo "✅ Extension $plugin is already installed"
                        else
                            echo "📦 Installing VSCode extension: $plugin"
                            "$vscode_cli" --install-extension "$plugin" || echo "⚠️  Failed to install $plugin"
                        fi
                        ;;
                    uninstall)
                        if "$vscode_cli" --list-extensions 2>/dev/null | grep -i "^${plugin}$" > /dev/null 2>&1; then
                            echo "🗑️  Uninstalling VSCode extension: $plugin"
                            "$vscode_cli" --uninstall-extension "$plugin" || echo "⚠️  Failed to uninstall $plugin"
                        else
                            echo "ℹ️  Extension $plugin is not installed"
                        fi
                        ;;
                esac
                ;;
            chrome|jetbrains)
                echo "⚠️  $action not implemented yet for $tool plugin $plugin"
                ;;
            *)
                echo "⚠️  Unknown tool: $tool"
                ;;
        esac
    done < "$file"

    echo "✅ $tool plugins $action complete!"
}

COMMAND="${1:-install}"

for plugin_file in "$PLUGINS_DIR"/*.txt; do
    [ -e "$plugin_file" ] || continue
    tool=$(basename "$plugin_file" .txt)
    case "$COMMAND" in
        install)
            process_plugin_file "$tool" "install"
            ;;
        clean|uninstall)
            process_plugin_file "$tool" "uninstall"
            ;;
        *)
            echo "Usage: $0 {install|clean|uninstall}"
            exit 1
            ;;
    esac
done
