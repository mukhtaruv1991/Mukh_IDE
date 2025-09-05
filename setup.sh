#!/data/data/com.termux/files/usr/bin/bash
# Mukh IDE - The Simple & Direct Installer (v9.1 - Clear Instructions)

echo "🚀 Welcome to the Mukh IDE Simple Installer!"
echo "--- Preparing your environment..."
pkg update -y && pkg upgrade -y > /dev/null 2>&1
packages_to_install=("git" "python" "curl" "tar")
for pkg_name in "${packages_to_install[@]}"; do
    if ! command -v "$pkg_name" &> /dev/null; then pkg install "$pkg_name" -y; fi
done

echo "--- Downloading the tools package..."
curl -L https://github.com/mukhtaruv1991/Mukh-IDE-Release/raw/main/Mukh-IDE.tar.gz -o Mukh-IDE.tar.gz
if [ $? -ne 0 ]; then exit 1; fi

echo "--- Unpacking tools into ~/Mukh-IDE..."
tar -xzvf Mukh-IDE.tar.gz -C ~
rm Mukh-IDE.tar.gz

echo ""
echo "--- ⚙️ Configuring your personal settings..."
# We run configure.sh using its full path
bash ~/Mukh-IDE/configure.sh

echo ""
echo "--- 🐍 Installing Python libraries..."
if ! python -c "import telegram" &> /dev/null; then pip install python-telegram-bot --upgrade; fi

echo ""
echo "🎉🎉🎉 SETUP COMPLETE! 🎉🎉🎉"
echo "The tools have been installed in the '~/Mukh-IDE' folder."
echo ""
echo "To start your bot, run these two commands:"
echo "------------------------------------------"
echo "1. Go into the project folder:"
echo "   cd ~/Mukh-IDE"
echo ""
echo "2. Run the bot:"
echo "   python Mukh_bot.py"
echo "------------------------------------------"
