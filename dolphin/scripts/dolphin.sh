#!/bin/bash

directory=$(dirname "$3" | cut -d "/" -f2)

for d in GC StateSaves ScreenShots Wii; do
  if [[ -d "/home/ark/.local/share/dolphin-emu/${d}" && ! -L "/home/ark/.local/share/dolphin-emu/${d}" ]]; then
    rm -rf /home/ark/.local/share/dolphin-emu/${d}
  fi
  if [[ ! -d "/$directory/gc/$d" ]]; then
    mkdir /$directory/gc/${d}
  fi
  ln -sf /$directory/gc/${d} /home/ark/.local/share/dolphin-emu/
done

export DOLPHIN_EMU_USERPATH="${HOME}/.local/share/dolphin-emu/"

if [[ "$(free -m | awk '/^Mem:/{print $2}')" -lt "1900" ]]; then
  if [[ -z "$(zramctl)" ]]; then
    printf "Enabling zram.  Please wait...\n" >> /dev/tty1
    sudo modprobe zram num_devices=1
    echo lz4 | sudo tee /sys/block/zram0/comp_algorithm
    echo 1G | sudo tee /sys/block/zram0/disksize
    sudo mkswap /dev/zram0
    sudo swapon /dev/zram0 -p 100
    printf "Launching dolphin emulation now" >> /dev/tty1
  fi
fi

# Aspect ratio
if [[ "$2" == "Normal" ]]; then
  sed -i '/AspectRatio =/c\AspectRatio = 2' ${HOME}/.local/share/dolphin-emu/Config/GFX.ini
  sed -i '/wideScreenHack =/c\wideScreenHack = False' ${HOME}/.local/share/dolphin-emu/Config/GFX.ini
else
  sed -i '/AspectRatio =/c\AspectRatio = 3' ${HOME}/.local/share/dolphin-emu/Config/GFX.ini
  sed -i '/wideScreenHack =/c\wideScreenHack = True' ${HOME}/.local/share/dolphin-emu/Config/GFX.ini
fi


LD_PRELOAD=/opt/dolphin/lib/libmali.so /opt/dolphin/dolphin-emu-nogui -p drm -a HLE -e "${3}"

printf "\033c" >> /dev/tty1
