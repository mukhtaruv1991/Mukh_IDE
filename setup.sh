#!/data/data/com.termux/files/usr/bin/bash
# Mukh IDE - The Ultimate Smart Installer (v4.0)

# --- PART 1: PREPARE THE ENVIRONMENT (SMART CHECK) ---
echo "🚀 Welcome to the Mukh IDE Ultimate Installer!"
echo "--- Preparing your environment (with smart checks)..."
pkg update -y && pkg upgrade -y > /dev/null 2>&1
    
packages_to_install=("git" "python" "curl" "tar")
for pkg_name in "${packages_to_install[@]}"; do
    if ! command -v "$pkg_name" &> /dev/null; then
        echo "Installing '$pkg_name'..."
        pkg install "$pkg_name" -y
    else
        echo "'$pkg_name' is already installed. Skipping."
    fi
done

# --- PART 2: DOWNLOAD AND UNPACK THE TOOLS ---
echo "--- Downloading the pre-built tools package..."
curl -L https://github.com/mukhtaruv1991/Mukh-IDE-Release/raw/main/mukh-ide-tools.tar.gz -o mukh-ide-tools.tar.gz
if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to download the package."
    exit 1
fi
echo "--- Unpacking tools..."
tar -xzvf mukh-ide-tools.tar.gz -C ~
rm mukh-ide-tools.tar.gz

# --- PART 3: CONFIGURE USER SETTINGS ---
echo ""
echo "--- ⚙️ Now, let's configure your personal settings (one-time setup)..."
bash ~/mukh-ide-tools/configure.sh

# --- PART 4: INSTALL PYTHON DEPENDENCIES (SMART CHECK) ---
echo ""
echo "--- 🐍 Installing Python libraries for the bot (with smart checks)..."
if ! python -c "import telegram" &> /dev/null; then
    echo "Installing 'python-telegram-bot'..."
    pip install python-telegram-bot --upgrade
else
    echo "'python-telegram-bot' is already installed. Skipping."
fi

# --- PART 5: FINAL INSTRUCTIONS ---
echo ""
echo "🎉🎉🎉 ALL DONE! 🎉🎉🎉"
echo "Your entire system is installed, configured, and ready to go."
echo ""
echo "To start your personal IDE bot, just run this command:"
echo "----------------------------------------------------"
echo "   python ~/mukh-ide-tools/manus_bot.py"
echo "----------------------------------------------------"
