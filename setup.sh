#!/data/data/com.termux/files/usr/bin/bash
# Mukh IDE - The Reliable Installer (v6.0 - Absolute Path Fix)

echo "🚀 Welcome to the Mukh IDE Reliable Installer!"
echo "--- Preparing your environment..."
pkg update -y && pkg upgrade -y > /dev/null 2>&1
packages_to_install=("git" "python" "curl" "tar")
for pkg_name in "${packages_to_install[@]}"; do
    if ! command -v "$pkg_name" &> /dev/null; then
        pkg install "$pkg_name" -y
    fi
done

echo "--- Downloading the tools package..."
curl -L https://github.com/mukhtaruv1991/Mukh-IDE-Release/raw/main/mukh-ide-tools.tar.gz -o mukh-ide-tools.tar.gz
if [ $? -ne 0 ]; then exit 1; fi

echo "--- Unpacking and setting up tools..."
tar -xzvf mukh-ide-tools.tar.gz -C ~
rm mukh-ide-tools.tar.gz

# THE RELIABLE FIX: Create symbolic links using the absolute path
echo "--- Creating global commands..."
TERMUX_BIN_DIR="/data/data/com.termux/files/usr/bin"
ln -sf ~/mukh-ide-tools/mukh-bot "$TERMUX_BIN_DIR/mukh-bot"
ln -sf ~/mukh-ide-tools/manus-core "$TERMUX_BIN_DIR/manus-core"

echo ""
echo "--- ⚙️ Configuring your personal settings..."
bash ~/mukh-ide-tools/configure.sh

echo ""
echo "--- 🐍 Installing Python libraries..."
if ! python -c "import telegram" &> /dev/null; then
    pip install python-telegram-bot --upgrade
fi

echo ""
echo "🎉🎉🎉 RELIABLE SETUP COMPLETE! 🎉🎉🎉"
echo "Your entire system is ready."
echo ""
echo "To start your bot from ANYWHERE, just type:"
echo "------------------------------------------"
echo "   mukh-bot"
echo "------------------------------------------"
