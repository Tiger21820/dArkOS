#!/bin/bash

event_num="3"
event_type="EV_KEY"
event_btn="BTN_SOUTH"
if [[ -e "/dev/input/by-path/platform-fe5b0000.i2c-event" ]]; then
  event_num="4"
  param_device="rg552"
elif [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  param_device="anbernic"
  event_num="3"
  event_btn="BTN_EAST"
elif [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
    if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000") ]]; then
      param_device="oga"
        else
          param_device="rk2020"
        fi
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  param_device="ogs"
elif [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
  param_device="rg552"
else
  param_device="chi"
fi

sudo chmod 666 /dev/tty1
export TERM=linux
export XDG_RUNTIME_DIR=/run/user/$UID/

function KillQuickMode(){
  if [[ -e /sys/devices/platform/ff400000.gpu/devfreq/ff400000.gpu/governor ]]; then
    echo simple_ondemand > /sys/devices/platform/ff400000.gpu/devfreq/ff400000.gpu/governor
  elif [[ -e /sys/devices/platform/fde60000.gpu/devfreq/fde60000.gpu/governor ]]; then
    echo dmc_ondemand > /sys/devices/platform/fde60000.gpu/devfreq/fde60000.gpu/governor
  fi
  echo interactive > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
  echo dmc_ondemand > /sys/devices/platform/dmc/devfreq/dmc/governor
  rm /dev/shm/QBMODE
  rm /home/ark/.config/lastgame.sh
}

evtest --query /dev/input/event$event_num $event_type $event_btn
if [ "$?" -eq "10" ]; then
  printf "\033c" > /dev/tty1
  sudo setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
  cd /usr/bin/emulationstation
  sudo ./boot_controls none $param_device &
  while true; do

          selection=(dialog \
          --backtitle "Boot and Recovery Tools" \
          --title "BaRT" \
          --no-collapse \
          --clear \
          --cancel-label "You must select one" \
          --menu "Distro: $(cat /usr/share/plymouth/themes/text.plymouth | grep ArkOS | cut -c 7-50)        Batt: $(cat /sys/class/power_supply/battery/capacity)%" 14 60 10)

          options=(
                  "1)" "Continue with Quick Mode boot"
                  "2)" "Quit to Emulationstation"
                  "3)" "Wifi"
                  "4)" "Enable Remote Services"
                  "5)" "351Files"
                  "6)" "Backup ArkOS Settings"
                  "7)" "Restore ArkOS Settings"
                  "8)" "Reboot"
                  "9)" "Power Off"
          )

          choices=$("${selection[@]}" "${options[@]}" 2>&1 > /dev/tty1)

          for choice in $choices; do
                  case $choice in
                          "1)") sudo kill -9 $(pidof boot_controls)
                                printf "\033c" > /dev/tty1
                                sudo systemctl restart ogage &
                                exit
                                ;;
                          "2)") sudo kill -9 $(pidof boot_controls)
                                KillQuickMode
                                sudo systemctl restart ogage &
                                sudo systemctl restart firstboot &
                                sudo systemctl restart emulationstation
                                exit
                                ;;
                          "3)") sudo kill -9 $(pidof boot_controls)
                                /opt/system/Wifi.sh
                                sudo ./boot_controls none $param_device &
                                ;;
                          "4)") /opt/system/Enable\ Remote\ Services.sh 2>&1 > /dev/tty1
                                ;;
                          "5)") /opt/system/351Files.sh 2>&1 > /dev/tty1
                                ;;
                          "6)") sudo kill -9 $(pidof boot_controls)
                                /opt/system/Advanced/"Backup ArkOS Settings.sh" 2>&1 > /dev/tty1
                                sudo ./boot_controls none $param_device &
                                ;;
                          "7)") sudo kill -9 $(pidof boot_controls)
                                /opt/system/Advanced/"Restore ArkOS Settings.sh" 2>&1 > /dev/tty1
                                sudo ./boot_controls none $param_device &
                                ;;
                          "8)") sudo reboot
                                ;;
                          "9)") sudo shutdown now
                                ;;
                  esac
          done
  done
fi