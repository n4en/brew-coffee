#!/bin/bash
set -euo pipefail

PLUGINS_DIR="./plugins"
 
# Detect OS type
if [ "$(uname -s)" = "Darwin" ]; then
    OS_TYPE="macos"
elif [ "$(uname -s)" = "Linux" ]; then
    OS_TYPE="linux"
elif [ -n "${WINDIR:-}" ]; then
    OS_TYPE="windows"
else
    OS_TYPE="unknown"
fi

# Find VS Code CLI based on platform
if command -v code >/dev/null 2>&1; then
    VSCODE_CLI="$(command -v code)"
else
    case "$OS_TYPE" in
        macos)
            if [ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]; then
                VSCODE_CLI="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
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
                    VSCODE_CLI="$path"
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
                    VSCODE_CLI="$path"
                    break
                fi
            done
            ;;
    esac
fi

# If VS Code CLI wasn't found, set it to empty
if [ -z "${VSCODE_CLI:-}" ]; then
    VSCODE_CLI=""
fi

install_plugins_for_tool() {
    local tool="$1"
    local file="$PLUGINS_DIR/$tool.txt"
    [ ! -f "$file" ] && return

    echo "☕ Installing $tool plugins..."
    # Debug: Show file contents
    echo "📄 Reading plugins from: $file"
    cat "$file"
    
    while IFS= read -r plugin || [ -n "$plugin" ]; do
        # Trim whitespace
        plugin=$(echo "$plugin" | tr -d '[:space:]')
        
        case "$plugin" in
            ""|\#*) 
                echo "⏭️  Skipping empty line or comment"
                continue 
                ;;
        esac

        case "$tool" in
            vscode)
                if [ -x "$VSCODE_CLI" ]; then
                    echo "🔍 Checking if $plugin is already installed..."
                    if ! "$VSCODE_CLI" --list-extensions | grep -i "^${plugin}$" > /dev/null; then
                        echo "📦 Installing VSCode extension: $plugin"
                        "$VSCODE_CLI" --install-extension "$plugin" || echo "⚠️ Failed to install $plugin"
                    else
                        echo "✅ Extension $plugin is already installed"
                    fi
                else
                    echo "⚠️ VSCode CLI not found at: $VSCODE_CLI"
                fi
                ;;
            chrome|jetbrains)
                echo "⚠️ Installation not implemented yet for $tool plugin $plugin"
                ;;
            *)
                echo "⚠️ Unknown tool: $tool"
                ;;
        esac
    done < "$file"
    echo "✅ $tool plugins installed!"
}

uninstall_plugins_for_tool() {
    local tool="$1"
    local file="$PLUGINS_DIR/$tool.txt"
    [ ! -f "$file" ] && return

    echo "🧹 Uninstalling $tool plugins..."
    echo "📄 Reading plugins from: $file"
    cat "$file"
    
    while IFS= read -r plugin || [ -n "$plugin" ]; do
        # Trim whitespace
        plugin=$(echo "$plugin" | tr -d '[:space:]')
        
        case "$plugin" in
            ""|\#*) 
                echo "⏭️  Skipping empty line or comment"
                continue 
                ;;
        esac

        case "$tool" in
            vscode)
                if [ -x "$VSCODE_CLI" ]; then
                    echo "🔍 Checking if $plugin is installed..."
                    if "$VSCODE_CLI" --list-extensions | grep -i "^${plugin}$" > /dev/null; then
                        echo "🗑️  Uninstalling VSCode extension: $plugin"
                        "$VSCODE_CLI" --uninstall-extension "$plugin" || echo "⚠️ Failed to uninstall $plugin"
                    else
                        echo "ℹ️  Extension $plugin is not installed"
                    fi
                else
                    echo "⚠️ VSCode CLI not found at: $VSCODE_CLI"
                fi
                ;;
            chrome|jetbrains)
                echo "⚠️ Uninstallation not implemented yet for $tool plugin $plugin"
                ;;
        esac
    done < "$file"
    echo "✅ $tool plugins uninstalled!"
}

COMMAND="${1:-install}"

for plugin_file in "$PLUGINS_DIR"/*.txt; do
    tool=$(basename "$plugin_file" .txt)
    case "$COMMAND" in
        install) install_plugins_for_tool "$tool" ;;
        clean|uninstall) uninstall_plugins_for_tool "$tool" ;;
        *) echo "Usage: $0 {install|clean}" ;;
    esac
done
