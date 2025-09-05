#!/data/data/com.termux/files/usr/bin/bash
# Mukh IDE - The Ultimate All-in-One Installer (v3.0)

# --- PART 1: PREPARE THE ENVIRONMENT ---
echo "🚀 Welcome to the Mukh IDE Ultimate Installer!"
echo "--- Preparing your environment..."
pkg update -y && pkg upgrade -y > /dev/null 2>&1
pkg install git python curl tar -y

# --- PART 2: DOWNLOAD AND UNPACK THE TOOLS ---
echo "--- Downloading the pre-built tools package..."
curl -L https://github.com/mukhtaruv1991/Mukh-IDE-Release/raw/main/mukh-ide-tools.tar.gz -o mukh-ide-tools.tar.gz
if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to download the package. Please check your internet connection."
    exit 1
fi
echo "--- Unpacking tools..."
tar -xzvf mukh-ide-tools.tar.gz -C ~
rm mukh-ide-tools.tar.gz

# --- PART 3: CONFIGURE USER SETTINGS ---
echo ""
echo "--- ⚙️ Now, let's configure your personal settings (one-time setup)..."
bash ~/mukh-ide-tools/configure.sh

# --- PART 4: INSTALL PYTHON DEPENDENCIES ---
echo ""
echo "--- 🐍 Installing Python libraries for the bot..."
pip install python-telegram-bot --upgrade

# --- PART 5: FINAL INSTRUCTIONS ---
echo ""
echo "🎉🎉🎉 ALL DONE! 🎉🎉🎉"
echo "Your entire system is installed, configured, and ready to go."
echo ""
echo "To start your personal IDE bot, just run this command:"
echo "----------------------------------------------------"
echo "   python ~/mukh-ide-tools/manus_bot.py"
echo "----------------------------------------------------"
