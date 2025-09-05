# Manus Bot Interface (v30.0 - Full Version)
import logging, os, subprocess, json
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Application, CommandHandler, CallbackQueryHandler, MessageHandler, filters, ContextTypes
from telegram.constants import ParseMode
logging.basicConfig(format="%(asctime)s - %(name)s - %(levelname)s - %(message)s", level=logging.INFO)
CONFIG_FILE = os.path.join(os.path.expanduser("~"), ".mukh_ide_config.json")
def load_config():
    try:
        with open(CONFIG_FILE) as f: return json.load(f)
    except: return None
def run_core_command(command):
    try:
        full_command = f"bash {os.path.expanduser('~/mukh-ide-tools/manus-core')} {command}"
        result = subprocess.run(full_command, shell=True, capture_output=True, text=True, timeout=600)
        return result.stdout.strip()
    except Exception as e: return f"Error: {e}"
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    k = [[InlineKeyboardButton("➕ مشروع جديد", callback_data='add_project_start')], [InlineKeyboardButton("📂 المشاريع الحالية", callback_data='list_projects')]]
    await update.message.reply_text("🤖 *Mukh IDE*", reply_markup=InlineKeyboardMarkup(k), parse_mode=ParseMode.MARKDOWN)
def main():
    config = load_config()
    if not config or not config.get("telegram_bot_token"):
        print("❌ CRITICAL: Bot token not found in ~/.mukh_ide_config.json")
        print("Please run the configuration script first.")
        return
    TOKEN = config.get("telegram_bot_token")
    app = Application.builder().token(TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    print("🤖 Mukh IDE Bot is running...")
    app.run_polling()
if __name__ == "__main__":
    main()
