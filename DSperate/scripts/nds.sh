#!/bin/bash

directory="$(dirname "$2" | cut -d "/" -f2)"

if [[ "$1" == "advanced_drastic" ]]; then
  for d in backup cheats savestates slot2; do
    if [[ ! -d "/${directory}/nds/$d" ]]; then
      mkdir /${directory}/nds/${d}
    fi
    if [[ -d "/opt/advanced_drastic/$d" && ! -L "/opt/advanced_drastic/$d" ]]; then
      cp -n /opt/advanced_drastic/${d}/* /${directory}/nds/${d}/
      rm -rf /opt/advanced_drastic/${d}/
    fi
    ln -sf /${directory}/nds/${d} /opt/advanced_drastic/
  done

  export LD_LIBRARY_PATH=/opt/advanced_drastic/libs:$LD_LIBRARY_PATH
  cd /opt/advanced_drastic
  unset LD_PRELOAD
  export LD_PRELOAD=/opt/advanced_drastic/libs/libadvdrastic.so

  echo "VAR=drastic" > /home/ark/.config/KILLIT
  sudo systemctl restart killer_daemon.service

  ./drastic_v2522 "$2"

  sudo systemctl stop killer_daemon.service

  sudo systemctl restart ogage &
elif [[ "$1" == "drastic" ]]; then
  for d in backup cheats savestates slot2; do
    if [[ ! -d "/${directory}/nds/$d" ]]; then
      mkdir /${directory}/nds/${d}
    fi
    if [[ -d "/opt/drastic/$d" && ! -L "/opt/drastic/$d" ]]; then
      cp -n /opt/drastic/${d}/* /${directory}/nds/${d}/
      rm -rf /opt/drastic/${d}/
    fi
    ln -sf /${directory}/nds/${d} /opt/drastic/
  done

  echo "VAR=drastic" > /home/ark/.config/KILLIT
  sudo systemctl restart killer_daemon.service

  cd /opt/drastic
  ./drastic "$2"

  sudo systemctl stop killer_daemon.service

  sudo systemctl restart ogage &
elif [[ "$1" == "dsperate" ]]; then
  # The DSperate standalone emulator does not support 7z archive files.  We'll take care of that here
  game="$2"
  ext="${2##*.}"
  if [[ "${ext,,}" == "7z" ]]; then
    if [ ! -d "/dev/shm/ndsroms" ]; then
      mkdir -p /dev/shm/ndsroms
    else
      rm -rf /dev/shm/ndsroms/*
    fi
    # game variable will be updated with the file that is found in the 7z archive
    ROM="$game"
    7z e "$ROM" -bd -aoa -o/dev/shm/ndsroms/

    if [ $? != 0 ]; then
      printf "\nCouldn't decompress $ROM\nSomething seems to be wrong with this archive." > /dev/tty1
      sleep 5
      printf "\033c" > /dev/tty1
      exit 1
    fi

    for CART in nds NDS; do
      game=`find /dev/shm/ndsroms/ -iname "*.${CART}" | tac | head -n 1`
      if [ ! -z "$game" ]; then
        break;
      fi
    done
    if [ -z "$game" ]; then
      printf "\nCouldn't find a compatible rom of type .nds or .NDS in $ROM\n" > /dev/tty1
      sleep 5
      printf "\033c" > /dev/tty1
      exit 1
    fi
  fi

  if [[ ! -d "/${directory}/nds/dsperate" ]]; then
    mkdir /${directory}/nds/dsperate
    cp /opt/DSperate/config/dsperate.ini /${directory}/nds/dsperate/.
  fi

  if [[ ! -s "/${directory}/nds/dsperate/dsperate.ini" ]]; then
    cp /opt/DSperate/config/dsperate.ini /${directory}/nds/dsperate/.
  fi

  ln -sfn /${directory}/nds/dsperate /home/ark/.config/

  if [[ ! -d "/${directory}/nds/cheats" ]]; then
    mkdir /${directory}/nds/cheats
  fi

  if [[ ! -d "/${directory}/nds/savestates" ]]; then
    mkdir /${directory}/nds/savestates
  fi

  sed -i "/saves =/c\saves = /${directory}/nds" /${directory}/nds/dsperate/dsperate.ini
  sed -i "/states =/c\states = /${directory}/nds/savestates" /${directory}/nds/dsperate/dsperate.ini
  sed -i "/cheats =/c\cheats = /${directory}/nds/cheats" /${directory}/nds/dsperate/dsperate.ini

  /opt/DSperate/dsperate "$game" --bios9 /${directory}/bios/nds_bios9.bin --bios7 /${directory}/bios/nds_bios7.bin --firmware /${directory}/bios/nds_firmware.bin

  if [ -d "/dev/shm/ndsroms" ]; then
    rm -rf /dev/shm/ndsroms
  fi
fi
