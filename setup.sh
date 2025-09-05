#!/data/data/com.termux/files/usr/bin/bash
echo "🚀 Installing Mukh IDE..."
echo "Downloading the pre-built tools package..."

# Download the pre-built package from your release repository
curl -L https://github.com/mukhtaruv1991/Mukh-IDE-Release/raw/main/mukh-ide-tools.tar.gz -o mukh-ide-tools.tar.gz

if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to download the package. Please check your internet connection."
    exit 1
fi

echo "Unpacking tools..."
# Unpack the tools into the user's home directory
tar -xzvf mukh-ide-tools.tar.gz -C ~

# Clean up the downloaded package
rm mukh-ide-tools.tar.gz

echo "✅ Installation complete! Your tools are ready."
echo "To start the bot, run: python ~/mukh-ide-tools/manus_bot.py"
