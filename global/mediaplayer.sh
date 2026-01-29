#!/bin/bash

xres="$(cat /sys/class/graphics/fb0/modes | grep -o -P '(?<=:).*(?=p-)' | cut -dx -f1)"
yres="$(cat /sys/class/graphics/fb0/modes | grep -o -P '(?<=:).*(?=p-)' | cut -dx -f2)"

sudo chmod 666 /dev/tty1
sudo chmod 666 /dev/uinput
export SDL_GAMECONTROLLERCONFIG_FILE="/opt/inttools/gamecontrollerdb.txt"
# This gaurd is specifically for the Chi to change the exit hotkey to be 1 and Start as other emulators and tools are for that unit
if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000") ]] || [[ -e "/dev/input/by-path/platform-gameforce-gamepad-event-joystick" ]]; then
  export HOTKEY="l3"
fi
/opt/inttools/gptokeyb -1 "ffplay" -c "/opt/inttools/mediaplayer.gptk" &
ffplay -loglevel +quiet -seek_interval 1 -loop 0 -x "$xres" -y "$yres" "$1"
unset SDL_GAMECONTROLLERCONFIG_FILE
if [[ ! -z $(pidof gptokeyb) ]]; then
  sudo kill -9 $(pidof gptokeyb)
fi
sudo systemctl restart ogage &
printf "\033c" >> /dev/tty1