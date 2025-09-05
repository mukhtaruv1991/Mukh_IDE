#!/data/data/com.termux/files/usr/bin/bash

# ==============================================================================
# Mukh IDE Universal Setup Script (v4.1 - Patched)
# This version fixes function scope issues for robust execution.
# ==============================================================================

# The entire logic is wrapped in a single main function to ensure scope.
main() {
    # --- UI Colors & Helper Functions (NOW INSIDE MAIN) ---
    C_BLUE="\e[34m"; C_GREEN="\e[32m"; C_YELLOW="\e[33m"; C_RED="\e[31m"; C_RESET="\e[0m"
    print_step() { echo -e "\n${C_BLUE}==> $1${C_RESET}"; }
    print_success() { echo -e "${C_GREEN}✅ $1${C_RESET}"; }
    print_warning() { echo -e "${C_YELLOW}⚠️ $1${C_RESET}"; }
    print_error() { echo -e "${C_RED}❌ $1${C_RESET}"; }
    prompt_input() {
        local prompt_text="$1"; local var_name="$2"; local default_value="$3"
        local value
        if [ -n "$default_value" ]; then
            read -p "$prompt_text [Press Enter to use: $default_value]: " value
            value=${value:-$default_value}
        else
            while true; do read -p "$prompt_text: " value; if [ -n "$value" ]; then break; else print_warning "This field cannot be empty."; fi; done
        fi
        eval "$var_name='$value'"
    }

    # --- Component Generators (NOW INSIDE MAIN) ---
    generate_manus_core() {
        local core_file_path="$1"
        cat > "$core_file_path" << 'EOC'
#!/data/data/com.termux/files/usr/bin/bash
# ==================================================
# Manus Core Engine (v20.0)
# ==================================================
CONFIG_FILE="$HOME/.manus_pro_config.json"
PROJECTS_DIR="$HOME/projects"
BACKUP_DIR="/storage/emulated/0/Manus_Backups"
AUTO_BACKUP_DIR="$BACKUP_DIR/auto_pre_fix"
MANUAL_BACKUP_DIR="$BACKUP_DIR/manual"
RESTORE_DIR="$HOME/restored_projects"
mkdir -p "$PROJECTS_DIR" "$AUTO_BACKUP_DIR" "$MANUAL_BACKUP_DIR" "$RESTORE_DIR"
_log_error() { echo "❌ ERROR: $1" >&2; }
_log_success() { echo "✅ SUCCESS: $1"; }
_log_info() { echo "ℹ️ INFO: $1"; }
_get_config() { grep -o "\"$1\": \"[^\"]*" "$CONFIG_FILE" | grep -o '[^"]*$'; }
main() {
    ACTION="$1"; shift
    case "$ACTION" in
        import)
            local source_path="$1"
            [ -z "$source_path" ] && { _log_error "Source path is required."; exit 1; }
            [ ! -d "$source_path" ] && { _log_error "Source path '$source_path' not found."; exit 1; }
            local project_name=$(basename "$source_path")
            local dest_path="$PROJECTS_DIR/$project_name"
            _log_info "Importing '$project_name' to '$dest_path'..."
            rsync -av --progress "$source_path/" "$dest_path/" --exclude 'build' --exclude '.git' --exclude '.idea' --exclude 'node_modules' --exclude '__pycache__' --exclude '*.pyc' --exclude '.DS_Store'
            echo -e "/build\n/node_modules\n.idea/\n*.iml\n*.pyc\n__pycache__/\n.DS_Store\n.env\nlocal.properties" > "$dest_path/.gitignore"
            _log_success "Project '$project_name' imported and .gitignore created."
            echo "$project_name"
            ;;
        init)
            local project_name="$1"; local repo_url="$2"; local project_path="$PROJECTS_DIR/$project_name"
            [ ! -d "$project_path" ] && { _log_error "Project '$project_name' not found."; exit 1; }
            [ -z "$repo_url" ] && { _log_error "GitHub repo URL is required."; exit 1; }
            cd "$project_path" || exit
            _log_info "Initializing Git for '$project_name'..."
            git init; git add .; git commit -m "Initial project setup"; git branch -M main
            git remote | grep -q "origin" && git remote set-url origin "$repo_url" || git remote add origin "$repo_url"
            _log_success "Git repo initialized and linked."
            ;;
        publish)
            local project_name="$1"; local commit_message="${2:-"Auto-commit by Manus Core"}"; local project_path="$PROJECTS_DIR/$project_name"
            [ ! -d "$project_path" ] && { _log_error "Project '$project_name' not found."; exit 1; }
            cd "$project_path" || exit
            _log_info "Publishing '$project_name'..."
            [ ! -d ".git" ] && { _log_error "Not a Git repository. Run 'init' first."; exit 1; }
            git add .
            if git diff-index --quiet --cached HEAD --; then
                _log_info "No changes. Forcing push to trigger workflows..."
                git commit --allow-empty -m "Trigger CI/CD"
            else
                git commit -m "$commit_message"
            fi
            _log_info "Pushing to remote 'origin'..."
            git push origin main
            _log_success "Project '$project_name' published."
            ;;
        backup)
            local project_name="$1"; local backup_type="manual"; [[ "$2" == "--type=auto" ]] && backup_type="auto"
            local project_path="$PROJECTS_DIR/$project_name"
            [ ! -d "$project_path" ] && { _log_error "Project '$project_name' not found."; exit 1; }
            local timestamp=$(date +%Y-%m-%d_%H-%M-%S); local backup_name="${backup_type}_${project_name}_${timestamp}.zip"
            local dest_dir; [ "$backup_type" == "auto" ] && dest_dir="$AUTO_BACKUP_DIR" || dest_dir="$MANUAL_BACKUP_DIR"
            local zip_file="$dest_dir/$backup_name"
            _log_info "Creating '$backup_type' backup for '$project_name'..."
            ( cd "$project_path" && zip -r "$zip_file" . -x 'build/*' '.git/*' 'node_modules/*' '__pycache__/*' '.idea/*' )
            if [ $? -eq 0 ]; then _log_success "Backup created: $zip_file"; echo "$zip_file"; else _log_error "Backup failed."; exit 1; fi
            ;;
        restore)
            local backup_name="$1"; local backup_path=""
            [ -f "$MANUAL_BACKUP_DIR/$backup_name" ] && backup_path="$MANUAL_BACKUP_DIR/$backup_name"
            [ -f "$AUTO_BACKUP_DIR/$backup_name" ] && backup_path="$AUTO_BACKUP_DIR/$backup_name"
            [ -z "$backup_path" ] && { _log_error "Backup '$backup_name' not found."; exit 1; }
            local restore_dir_name=$(basename "$backup_name" .zip); local restore_path="$RESTORE_DIR/$restore_dir_name"
            mkdir -p "$restore_path"
            _log_info "Restoring '$backup_name' to '$restore_path'..."
            unzip -o "$backup_path" -d "$restore_path"
            _log_success "Backup restored."
            ;;
        list)
            case "$1" in
                projects) ls -1 "$PROJECTS_DIR";;
                backups) (ls -1t "$MANUAL_BACKUP_DIR"/*.zip 2>/dev/null; ls -1t "$AUTO_BACKUP_DIR"/*.zip 2>/dev/null) | xargs -r -n 1 basename;;
                storage) ls -1d /storage/emulated/0/*/;;
                *) _log_error "Invalid list type: use 'projects', 'backups', or 'storage'.";;
            esac
            ;;
        *)
            echo "Manus Core Engine - Help"; echo "Usage: manus-core <command> [options]"
            echo "Commands: import, init, publish, backup, restore, list"
            ;;
    esac
}; main "$@"
EOC
        chmod +x "$core_file_path"
    }

    generate_manus_bot() {
        local bot_file_path="$1"
        cat > "$bot_file_path" << 'EOB'
# ==================================================
# Manus Bot Interface (v20.0)
# ==================================================
import logging, os, subprocess, json, re
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Application, CommandHandler, CallbackQueryHandler, MessageHandler, filters, ContextTypes
from telegram.constants import ParseMode

# --- Setup ---
logging.basicConfig(format="%(asctime)s - %(name)s - %(levelname)s - %(message)s", level=logging.INFO)
CONFIG_FILE = os.path.join(os.path.expanduser("~"), ".manus_pro_config.json")

def load_config():
    try:
        with open(CONFIG_FILE) as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        logging.critical("CRITICAL: Config file not found or corrupted. Run setup script.")
        return None

config = load_config()
if not config: exit()

TOKEN = config.get("telegram_bot_token")
PROJECTS_DIR = os.path.join(os.path.expanduser("~"), "projects")

# --- Helper Functions ---
def run_core_command(command):
    try:
        full_command = f"bash {os.path.expanduser('~/bin/manus-core')} {command}"
        result = subprocess.run(full_command, shell=True, capture_output=True, text=True, timeout=600)
        return result.stdout.strip()
    except Exception as e:
        return f"Error executing core command: {e}"

# --- UI Generation ---
def get_main_menu():
    keyboard = [
        [InlineKeyboardButton("➕ مشروع جديد", callback_data='add_project_start')],
        [InlineKeyboardButton("📂 المشاريع الحالية", callback_data='list_projects')]
    ]
    return InlineKeyboardMarkup(keyboard), "🤖 *Mukh IDE (v20.0)*\n\nأهلاً بك! اختر إجراءً للبدء."

def get_add_project_menu():
    keyboard = [
        [InlineKeyboardButton("📁 من مجلدات Termux", callback_data='import_termux')],
        [InlineKeyboardButton("🔙 القائمة الرئيسية", callback_data='main_menu')]
    ]
    return InlineKeyboardMarkup(keyboard), "➕ *إضافة مشروع جديد*\n\nمن أين تريد استيراد المشروع؟"

def get_project_dashboard_menu(project_name):
    keyboard = [
        [InlineKeyboardButton("🚀 نشر (Publish)", callback_data=f'publish_{project_name}')],
        [InlineKeyboardButton("🛡️ نسخ احتياطي", callback_data=f'backup_{project_name}')],
        [InlineKeyboardButton("🔙 العودة للمشاريع", callback_data='list_projects')]
    ]
    return InlineKeyboardMarkup(keyboard), f"🛠️ *مشروع: {project_name}*\n\nاختر إجراءً."

# --- Handlers ---
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    context.user_data.clear()
    reply_markup, text = get_main_menu()
    await update.message.reply_text(text, reply_markup=reply_markup, parse_mode=ParseMode.MARKDOWN)

async def button_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()
    command = query.data

    if command == 'main_menu':
        reply_markup, text = get_main_menu()
        await query.edit_message_text(text, reply_markup=reply_markup, parse_mode=ParseMode.MARKDOWN)
        
    elif command == 'list_projects':
        projects_raw = run_core_command("list projects")
        projects = sorted([p for p in projects_raw.split('\n') if p])
        if not projects:
            keyboard = [[InlineKeyboardButton("➕ إضافة مشروع", callback_data='add_project_start')]]
            await query.edit_message_text("لا توجد مشاريع حالية. هل تريد إضافة مشروع جديد؟", reply_markup=InlineKeyboardMarkup(keyboard))
            return
        keyboard = [[InlineKeyboardButton(p, callback_data=f'project_{p}')] for p in projects]
        keyboard.append([InlineKeyboardButton("🔙 القائمة الرئيسية", callback_data='main_menu')])
        await query.edit_message_text("📂 *المشاريع الحالية*\n\nاختر مشروعًا:", reply_markup=InlineKeyboardMarkup(keyboard), parse_mode=ParseMode.MARKDOWN)

    elif command.startswith('project_'):
        project_name = command.split('_', 1)[1]
        context.user_data['current_project'] = project_name
        reply_markup, text = get_project_dashboard_menu(project_name)
        await query.edit_message_text(text, reply_markup=reply_markup, parse_mode=ParseMode.MARKDOWN)

    elif command == 'add_project_start':
        reply_markup, text = get_add_project_menu()
        await query.edit_message_text(text, reply_markup=reply_markup, parse_mode=ParseMode.MARKDOWN)

    elif command == 'import_termux':
        await query.edit_message_text("للاستيراد من Termux، أرسل المسار الكامل للمشروع (مثال: `~/my-awesome-app`).", parse_mode=ParseMode.MARKDOWN)
        context.user_data['state'] = 'awaiting_import_path'

    elif command.startswith('publish_'):
        project_name = command.split('_', 1)[1]
        await query.edit_message_text(f"🚀 جاري نشر المشروع: `{project_name}`...", parse_mode=ParseMode.MARKDOWN)
        output = run_core_command(f"publish '{project_name}'")
        reply_markup, _ = get_project_dashboard_menu(project_name)
        await query.edit_message_text(f"✅ *نتيجة النشر:*\n\n```\n{output[:3500]}\n```", reply_markup=reply_markup, parse_mode=ParseMode.MARKDOWN)

    elif command.startswith('backup_'):
        project_name = command.split('_', 1)[1]
        await query.edit_message_text(f"🛡️ جاري أخذ نسخة احتياطية من: `{project_name}`...", parse_mode=ParseMode.MARKDOWN)
        output = run_core_command(f"backup '{project_name}'")
        backup_file_path = output.split(":")[-1].strip()
        await context.bot.send_document(chat_id=query.effective_chat.id, document=open(backup_file_path, 'rb'), caption=f"نسخة احتياطية يدوية للمشروع {project_name}")
        reply_markup, _ = get_project_dashboard_menu(project_name)
        await query.edit_message_text(f"✅ تم إنشاء النسخة الاحتياطية بنجاح.", reply_markup=reply_markup)

async def text_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    state = context.user_data.get('state')
    text = update.message.text

    if state == 'awaiting_import_path':
        await update.message.reply_text(f"⏳ جاري استيراد المشروع من المسار: `{text}`...", parse_mode=ParseMode.MARKDOWN)
        project_name = run_core_command(f"import '{text}'")
        if "ERROR" in project_name:
            await update.message.reply_text(f"❌ فشل الاستيراد:\n`{project_name}`", parse_mode=ParseMode.MARKDOWN)
        else:
            await update.message.reply_text(f"✅ تم استيراد المشروع بنجاح باسم: `{project_name}`.\n\nالآن، أرسل رابط مستودع GitHub لربطه (مثال: `https://github.com/user/repo.git`).", parse_mode=ParseMode.MARKDOWN)
            context.user_data['state'] = 'awaiting_repo_url'
            context.user_data['import_project_name'] = project_name
        
    elif state == 'awaiting_repo_url':
        project_name = context.user_data.get('import_project_name')
        await update.message.reply_text(f"⏳ جاري ربط المشروع `{project_name}` بالمستودع...", parse_mode=ParseMode.MARKDOWN)
        output = run_core_command(f"init '{project_name}' '{text}'")
        await update.message.reply_text(f"✅ *نتيجة الربط:*\n\n```\n{output}\n```\n\nتم تجهيز المشروع بنجاح!", parse_mode=ParseMode.MARKDOWN)
        context.user_data.clear()
        reply_markup, text = get_project_dashboard_menu(project_name)
        await update.message.reply_text(text, reply_markup=reply_markup, parse_mode=ParseMode.MARKDOWN)

def bot_main():
    if not TOKEN:
        print("FATAL: Bot token not found in config. Exiting.")
        return
    app = Application.builder().token(TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CallbackQueryHandler(button_handler))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, text_handler))
    print("🤖 Mukh IDE Bot (v20.0) is running...")
    app.run_polling()

if __name__ == "__main__":
    bot_main()
EOB
    }

    # --- Main Setup Logic (NOW INSIDE MAIN) ---
    clear
    echo -e "${C_BLUE}####################################################${C_RESET}"
    echo -e "${C_BLUE}#         Welcome to the Mukh IDE Setup          #${C_RESET}"
    echo -e "${C_BLUE}# This will build your personal development suite.   #${C_RESET}"
    echo -e "${C_BLUE}####################################################${C_RESET}"

    print_step "Checking and installing required packages..."
    pkg update -y && pkg upgrade -y > /dev/null 2>&1
    packages_to_install=("git" "python" "rsync" "zip" "gh")
    for pkg_name in "${packages_to_install[@]}"; do
        if ! command -v "$pkg_name" &> /dev/null; then
            echo "Installing '$pkg_name'..."
            pkg install "$pkg_name" -y
        else
            echo "'$pkg_name' is already installed. Skipping."
        fi
    done
    pip_packages_to_install=("python-telegram-bot" "google-generativeai")
    for pip_pkg in "${pip_packages_to_install[@]}"; do
        if ! python -c "import ${pip_pkg//-/_}" &> /dev/null; then
            echo "Installing '$pip_pkg' for Python..."
            pip install "$pip_pkg" --upgrade > /dev/null 2>&1
        else
            echo "'$pip_pkg' is already installed. Skipping."
        fi
    done
    print_success "All dependencies are satisfied."

    print_step "Gathering your personal keys and tokens..."
    CONFIG_FILE="$HOME/.manus_pro_config.json"
    OLD_TELEGRAM_TOKEN=""; OLD_TELEGRAM_CHAT_ID=""; OLD_GEMINI_API_KEY=""
    if [ -f "$CONFIG_FILE" ]; then
        print_success "Found existing configuration file. Loading values..."
        OLD_TELEGRAM_TOKEN=$(grep -o '"telegram_bot_token": "[^"]*' "$CONFIG_FILE" | grep -o '[^"]*$' || echo "")
        OLD_TELEGRAM_CHAT_ID=$(grep -o '"telegram_chat_id": "[^"]*' "$CONFIG_FILE" | grep -o '[^"]*$' || echo "")
        OLD_GEMINI_API_KEY=$(grep -o '"gemini_api_key": "[^"]*' "$CONFIG_FILE" | grep -o '[^"]*$' || echo "")
    fi
    prompt_input "Enter your Telegram Bot Token" TELEGRAM_TOKEN "$OLD_TELEGRAM_TOKEN"
    prompt_input "Enter your Telegram Chat ID" TELEGRAM_CHAT_ID "$OLD_TELEGRAM_CHAT_ID"
    prompt_input "Enter your Gemini API Key" GEMINI_API_KEY "$OLD_GEMINI_API_KEY"

    print_step "Configuring GitHub access..."
    OLD_GITHUB_USERNAME=""; OLD_GITHUB_EMAIL=""
    if gh auth status &> /dev/null; then
        print_success "Already logged into GitHub."
        OLD_GITHUB_USERNAME=$(git config --global user.name)
        OLD_GITHUB_EMAIL=$(git config --global user.email)
    else
        print_warning "Not logged into GitHub. Please follow the prompts."
        gh auth login
    fi
    if [ -z "$OLD_GITHUB_USERNAME" ]; then OLD_GITHUB_USERNAME=$(gh api user --jq .login 2>/dev/null); fi
    prompt_input "Enter your GitHub Username" GITHUB_USERNAME "$OLD_GITHUB_USERNAME"
    prompt_input "Enter your GitHub Email" GITHUB_EMAIL "$OLD_GITHUB_EMAIL"

    print_step "Generating your personal Mukh IDE tools..."
    TOOLS_DIR="$HOME/mukh-ide-tools"
    BIN_DIR="$HOME/bin"
    mkdir -p "$BIN_DIR"
    rm -rf "$TOOLS_DIR"
    mkdir -p "$TOOLS_DIR"

    generate_manus_core "$TOOLS_DIR/manus-core"
    print_success "Generated 'manus-core' engine."
        
    generate_manus_bot "$TOOLS_DIR/manus_bot.py"
    print_success "Generated 'manus_bot.py' interface."

    cat > "$TOOLS_DIR/README.md" << EOR
# My Personal Mukh IDE Tools
This repository contains my personal, auto-generated instance of the Mukh IDE suite.
EOR
    print_success "Generated 'README.md'."

    print_step "Setting up your private 'my-mukh-ide-tools' repository on GitHub..."
    cd "$TOOLS_DIR"
    REPO_NAME="my-mukh-ide-tools"
    git init
    git config --global user.name "$GITHUB_USERNAME"
    git config --global user.email "$GITHUB_EMAIL"
        
    if gh repo view "$GITHUB_USERNAME/$REPO_NAME" &> /dev/null; then
        print_warning "Repository '$REPO_NAME' already exists. Syncing..."
        git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
        git pull origin main --allow-unrelated-histories
    else
        print_step "Creating new private repository '$REPO_NAME'..."
        gh repo create "$REPO_NAME" --private --source=. --remote=origin
    fi
        
    git add .
    git commit -m "Deploy/Update Mukh IDE Tools (v4.1)"
    git push -u origin main -f
    print_success "Pushed your personal tools to your private repository."

    print_step "Saving your final configuration securely..."
    cat > "$CONFIG_FILE" << EOL
{
  "telegram_bot_token": "$TELEGRAM_TOKEN",
  "telegram_chat_id": "$TELEGRAM_CHAT_ID",
  "gemini_api_key": "$GEMINI_API_KEY",
  "github_username": "$GITHUB_USERNAME",
  "github_email": "$GITHUB_EMAIL",
  "mukh_ide_tools_repo": "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
}
EOL
    print_success "Global configuration saved to $CONFIG_FILE."

    echo -e "\n${C_GREEN}#############################################${C_RESET}"
    echo -e "${C_GREEN}#   Setup Complete! Welcome to Mukh IDE.    #${C_RESET}"
    echo -e "${C_GREEN}#############################################${C_RESET}"
    echo -e "\n${C_YELLOW}YOUR SYSTEM IS READY TO USE:${C_RESET}"
    echo "1. To start your bot, run: ${C_GREEN}python $TOOLS_DIR/manus_bot.py${C_RESET}"
    echo "2. To use the command-line tool, just type: ${C_GREEN}manus-core${C_RESET}"
}

# --- Run the main setup function ---
main
