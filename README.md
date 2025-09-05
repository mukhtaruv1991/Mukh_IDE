# Mukh IDE - Installer

Welcome to Mukh IDE! This repository contains the universal installer for a powerful Termux-based development suite, managed via a Telegram bot.

The installer will build a **private, personalized** set of tools for you on your device and in your own GitHub account.

## 🚀 One-Command Installation

To get started, open Termux and paste the following commands. This will download the installer and begin the setup process.

```bash
pkg update && pkg upgrade -y
pkg install git -y
git clone https://github.com/mukhtaruv1991/Mukh_IDE.git
cd Mukh_IDE
bash setup.sh
