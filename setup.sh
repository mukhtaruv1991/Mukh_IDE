#!/data/data/com.termux/files/usr/bin/bash
# Mukh IDE - The Simple & Direct Installer (v9.0)

echo "🚀 Welcome to the Mukh IDE Simple Installer!"
echo "--- Preparing your environment..."
pkg update -y && pkg upgrade -y > /dev/null 2>&1
packages_to_install=("git" "python" "curl" "tar")
for pkg_name in "${packages_to_install[@]}"; do
    if ! command -v "$pkg_name" &> /dev/null; then pkg install "$pkg_name" -y; fi
done

echo "--- Downloading the tools package..."
# Note the new package name
curl -L https://github.com/mukhtaruv1991/Mukh-IDE-Release/raw/main/Mukh-IDE.tar.gz -o Mukh-IDE.tar.gz
if [ $? -ne 0 ]; then exit 1; fi

echo "--- Unpacking tools into ~/Mukh-IDE..."
# Unpack and create the main folder
tar -xzvf Mukh-IDE.tar.gz -C ~
rm Mukh-IDE.tar.gz

# Go directly into the new folder
cd ~/Mukh-IDE

echo ""
echo "--- ⚙️ Configuring your personal settings..."
bash configure.sh

echo ""
echo "--- 🐍 Installing Python libraries..."
if ! python -c "import telegram" &> /dev/null; then pip install python-telegram-bot --upgrade; fi

echo ""
echo "🎉🎉🎉 SETUP COMPLETE! 🎉🎉🎉"
echo "You are now inside the project folder: ~/Mukh-IDE"
echo ""
echo "To start your bot, just run this command:"
echo "------------------------------------------"
echo "   python Mukh_bot.py"
echo "------------------------------------------"
