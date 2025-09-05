#!/data/data/com.termux/files/usr/bin/bash
# Mukh IDE - The God-Tier Installer (v40.0)
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
echo "🚀 Welcome to the Mukh IDE God-Tier Installer!"
echo "--- Preparing environment..."
pkg update -y && pkg upgrade -y > /dev/null 2>&1
pkg install git python curl tar gh -y
echo "--- Downloading tools..."
curl -L https://github.com/mukhtaruv1991/Mukh-IDE-Release/raw/main/Mukh-IDE.tar.gz -o Mukh-IDE.tar.gz
if [ $? -ne 0 ]; then echo "❌ Download failed!"; exit 1; fi
echo "--- Unpacking tools..."
rm -rf ~/Mukh-IDE
tar -xzvf Mukh-IDE.tar.gz -C ~
rm Mukh-IDE.tar.gz
echo "--- ⚙️ Configuring personal settings..."
bash ~/Mukh-IDE/configure.sh
echo "--- 🐍 Installing Python libraries..."
pip install "python-telegram-bot[job-queue]" --upgrade
echo "--- ✨ Creating 'mukh-start' command..."
create_start_command
echo -e "\n🎉🎉🎉 SETUP COMPLETE! 🎉🎉🎉"
echo "Starting the bot for the first time..."
mukh-start
