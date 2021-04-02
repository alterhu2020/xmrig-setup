#!/bin/bash

VERSION=1.0

# printing greetings

echo "xmrig mining uninstall script v$VERSION."
echo "(please report issues to alterhu2020@gmail.com email with full output of this script with extra \"-x\" \"bash\" option)"
echo

if [ -z $HOME ]; then
  echo "ERROR: Please define HOME environment variable to your home directory"
  exit 1
fi

if [ ! -d $HOME ]; then
  echo "ERROR: Please make sure HOME directory $HOME exists"
  exit 1
fi

echo "[*] Removing xmrig miner"
if sudo -n true 2>/dev/null; then
  sudo systemctl stop xmrig_miner.service
  sudo systemctl disable xmrig_miner.service
  rm -f /etc/systemd/system/xmrig_miner.service
  sudo systemctl daemon-reload
  sudo systemctl reset-failed
fi

sed -i '/xmrig/d' $HOME/.profile
killall -9 xmrig

echo "[*] Removing $HOME/xmrig directory"
rm -rf $HOME/xmrig

echo "[*] Uninstall complete"

