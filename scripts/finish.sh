#!/bin/bash
if [ ! -e "/home/ark/.config/.SWAPPOWERANDSUSPEND" ]; then
  printf "\033c" >> /dev/tty1
  sudo systemctl stop emulationstation
  sudo systemctl poweroff
else
  sudo systemctl suspend
fi
