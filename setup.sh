#!/data/data/com.termux/files/usr/bin/bash
# Mukh IDE - All-in-One Installer (v2.0)

echo "🚀 Installing Mukh IDE..."
echo "Downloading the pre-built tools package..."

# Download the pre-built package
curl -L https://github.com/mukhtaruv1991/Mukh-IDE-Release/raw/main/mukh-ide-tools.tar.gz -o mukh-ide-tools.tar.gz

if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to download the package."
    exit 1
fi

echo "Unpacking tools..."
# Unpack the tools into the user's home directory
tar -xzvf mukh-ide-tools.tar.gz -C ~

# Clean up the downloaded package
rm mukh-ide-tools.tar.gz

echo "✅ Tools installed successfully."
echo ""
echo "--- ⚙️ Now, let's configure your settings ---"

# --- STEP 2: Automatically run the configuration script ---
bash ~/mukh-ide-tools/configure.sh

echo ""
echo "🎉 All Done! Your system is fully configured and ready."
echo "To start the bot, run: python ~/mukh-ide-tools/manus_bot.py"
