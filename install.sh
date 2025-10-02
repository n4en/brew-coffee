#!/bin/bash
# ==========================================
# brew-coffee installer
# Install curated Homebrew Bundles
# ==========================================

BUNDLES_DIR="./bundles"

# Check if Homebrew is installed
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo "⚡ Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo "✅ Homebrew installed successfully!"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo "✅ Homebrew is already installed."
    fi
}

# Install a bundle
install_bundle() {
    local bundle_name="$1"
    local bundle_file="$BUNDLES_DIR/${bundle_name}.Brewfile"

    if [ ! -f "$bundle_file" ]; then
        echo "❌ Bundle '$bundle_name' does not exist in $BUNDLES_DIR."
        return 1
    fi

    echo "☕ Installing '$bundle_name' bundle..."
    brew bundle install --file="$bundle_file"
    echo "✅ '$bundle_name' bundle installation complete!"
    echo
}

# Main
check_homebrew

if [ $# -eq 0 ]; then
    echo "⚡ No bundle specified. Installing all bundles..."
    for file in "$BUNDLES_DIR"/*.Brewfile; do
        bundle_name=$(basename "$file" .Brewfile)
        install_bundle "$bundle_name"
    done
else
    for bundle_name in "$@"; do
        install_bundle "$bundle_name"
    done
fi

echo "🎉 All requested bundles installed!"
exit 0
