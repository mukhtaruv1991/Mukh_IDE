#!/data/data/com.termux/files/usr/bin/bash
# Mukh IDE - The Stable Launcher Installer (v33.0)
create_start_command() {
    cat > /data/data/com.termux/files/usr/bin/mukh-start << 'EOS'
#!/data/data/com.termux/files/usr/bin/bash
echo "🚀 Launching Mukh IDE Bot..."
pkill -f "python Mukh_bot.py"
cd ~/Mukh-IDE
python Mukh_bot.py
EOS
    chmod +x /data/data/com.termux/files/usr/bin/mukh-start
}
echo "🚀 Welcome to the Mukh IDE Stable Launcher!"
echo "--- Preparing your environment..."
pkg update -y && pkg upgrade -y > /dev/null 2>&1
packages_to_install=("git" "python" "curl" "tar")
for pkg_name in "${packages_to_install[@]}"; do
    if ! command -v "$pkg_name" &> /dev/null; then pkg install "$pkg_name" -y; fi
done
echo "--- Downloading the tools package..."
curl -L https://github.com/mukhtaruv1991/Mukh-IDE-Release/raw/main/Mukh-IDE.tar.gz -o Mukh-IDE.tar.gz
if [ $? -ne 0 ]; then echo "❌ Download failed!"; exit 1; fi
echo "--- Unpacking tools into ~/Mukh-IDE..."
rm -rf ~/Mukh-IDE
tar -xzvf Mukh-IDE.tar.gz -C ~
rm Mukh-IDE.tar.gz
echo "--- ⚙️ Configuring your personal settings..."
bash ~/Mukh-IDE/configure.sh
echo "--- 🐍 Installing Python libraries..."
pip install python-telegram-bot --upgrade
echo "--- ✨ Creating the 'mukh-start' command..."
create_start_command
echo ""
echo "🎉🎉🎉 SETUP COMPLETE! 🎉🎉🎉"
echo "The system is fully installed. Starting the bot for the first time..."
echo ""
mukh-start
