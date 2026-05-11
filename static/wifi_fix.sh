#!/bin/sh

TARGET_FILE='/etc/default/grub'
CMD_LINE='curl -sL https://lexiz.xyz/wifi_fix.sh | sudo bash'

[ $EUID -ne 0 ] && echo "[-] Please run this script as root with: $CMD_LINE" && exit 1

echo "[+] Modify $TARGET_FILE"
perl -i.bak -pe 's/^(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*)/$1 amdgpu.dcdebugmask=0x12/' $TARGET_FILE

echo "[+] Updating grub"
update-grub

echo "[+] All good ! Feel free to reboot :)"
