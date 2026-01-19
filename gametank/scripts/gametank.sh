#!/bin/bash

if [[ $1 == "standalone" ]]; then
  export ALSA_CONFIG_PATH="/usr/share/alsa/alsa.conf.gametank"
  cp -f /home/ark/.asoundrc /home/ark/.asoundrc.gametank
  if [[ "$(tr -d '\0' < /proc/device-tree/compatible)" == *"rk3566"* ]]; then
    sed -i '/ipc_key         1024/s//ipc_key         1024\n        ipc_key_add_uid 1/' /home/ark/.asoundrc.gametank
  else
    sed -i '/ipc_key 1024/s//ipc_key 1024\n ipc_key_add_uid 1/' /home/ark/.asoundrc.gametank
  fi

  echo "VAR=GameTankEmulator" > /home/ark/.config/KILLIT
  sudo systemctl restart killer_daemon.service

  sudo chmod 666 /dev/uinput
  export SDL_GAMECONTROLLERCONFIG_FILE="/opt/inttools/gamecontrollerdb.txt"
  /opt/inttools/gptokeyb -c "/opt/gametank/gametank.gptk" > /dev/null &

  /opt/gametank/GameTankEmulator "$2"

  pgrep -f gptokeyb | sudo xargs kill -9
  unset SDL_GAMECONTROLLERCONFIG_FILE

  sudo systemctl stop killer_daemon.service
  sudo systemctl restart ogage &
else
  /usr/local/bin/"$1" -L /home/ark/.config/"$1"/cores/"$2"_libretro.so "$3"
fi