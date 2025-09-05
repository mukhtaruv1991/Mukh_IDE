#!/data/data/com.termux/files/usr/bin/bash
echo "--- Mukh IDE Configuration ---"
CONFIG_FILE="$HOME/.mukh_ide_config.json"
read -p "Enter your Telegram Bot Token: " TELEGRAM_TOKEN
read -p "Enter your Telegram Chat ID: " TELEGRAM_CHAT_ID
read -p "Enter your GitHub Username: " GITHUB_USERNAME
cat > "$CONFIG_FILE" << EOL
{
  "telegram_bot_token": "$TELEGRAM_TOKEN",
  "telegram_chat_id": "$TELEGRAM_CHAT_ID",
  "github_username": "$GITHUB_USERNAME"
}
EOL
echo "✅ Configuration saved to $CONFIG_FILE"
