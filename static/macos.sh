#!/bin/bash

if [ "$EUID" -ne 0 ]; then echo "[-] Please run this script with sudo."; exit 1; fi

printf "Enter new username: " && read -r USERNAME < /dev/tty
printf "Enter password for $USERNAME: " && read -s -r PASSWORD < /dev/tty
echo ""
printf "Enter password for current admin ($CURRENT_ADMIN): " && read -s -r ADMIN_PASSWORD < /dev/tty
echo ""

echo "[+] Creating admin user and granting FileVault access..."
sysadminctl -addUser "$USERNAME" \
  -password "$PASSWORD" \
  -adminUser "admin" \
  -adminPassword "$ADMIN_PASSWORD" \
  -admin

echo "[+] Refreshing FileVault boot screen..."
diskutil apfs updatePreboot /

echo "[+] Renaming Mac..."
scutil --set ComputerName "${USERNAME} Macbook NEO"
scutil --set LocalHostName "$USERNAME-Macbook-NEO"
scutil --set HostName "$USERNAME-Macbook-NEO"

# TODO: figure how to download and install Chrome, Discord, OnlyOffie automatically
#echo "[+] Downloading dmgs to ~/Downloads/"
#curl -L -o "$HOME/Downloads/Chrome.dmg" "https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg"
#curl -L -o "$HOME/Downloads/Discord.dmg" "https://discord.com/api/download?platform=osx"
#curl -L -o "$HOME/Downloads/OnlyOffice.dmg" "https://download.onlyoffice.com/install/desktop/editors/mac/ONLYOFFICE.dmg"

echo "[+] Done!"
