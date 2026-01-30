#!/bin/bash
if [ ! -e "/home/ark/.config/.SWAPPOWERANDSUSPEND" ]; then
  sudo systemctl suspend
else
  printf "\033c" >> /dev/tty1
  sudo systemctl stop emulationstation
  sudo systemctl poweroff
fi
