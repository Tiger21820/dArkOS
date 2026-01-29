#!/bin/bash

export SDL_ASSERT="always_ignore"

. /usr/local/bin/buttonmon.sh

boot_controls() {
  export DIALOGRC=/opt/inttools/noshadows.dialogrc
  printf "\033c" > /dev/tty1
  if [[ ! -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
    if test ! -z "$(cat /home/ark/.config/.DEVICE | grep RGB20PRO | tr -d '\0')"
    then
      sudo setfont /usr/share/consolefonts/Lat7-TerminusBold32x16.psf.gz
    else
      sudo setfont /usr/share/consolefonts/Lat7-TerminusBold28x14.psf.gz
    fi
  else
    sudo setfont /usr/share/consolefonts/Lat7-Terminus16.psf.gz
  fi

  if [[ -z $(pgrep -f gptokeyb) ]] && [[ -z $(pgrep -f oga_controls) ]]; then
    sudo chmod 666 /dev/uinput
    export SDL_GAMECONTROLLERCONFIG_FILE="/opt/inttools/gamecontrollerdb.txt"
    /opt/inttools/gptokeyb -c "/opt/inttools/keys.gptk" > /dev/null &
    disown
    set_gptokeyb="Y"
  fi
}

kill_boot_controls() {
  if [[ ! -z "$set_gptokeyb" ]]; then
    pgrep -f gptokeyb | sudo xargs kill -9
    unset SDL_GAMECONTROLLERCONFIG_FILE
  fi
}

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

Test_Button_B
if [ "$?" -eq "10" ]; then
  printf "\033c" > /dev/tty1
  if [[ ! -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
    if test ! -z "$(cat /home/ark/.config/.DEVICE | grep RGB20PRO | tr -d '\0')"
    then
      sudo setfont /usr/share/consolefonts/Lat7-TerminusBold32x16.psf.gz
    else
      sudo setfont /usr/share/consolefonts/Lat7-TerminusBold28x14.psf.gz
    fi
  else
    sudo setfont /usr/share/consolefonts/Lat7-Terminus16.psf.gz
  fi
  cd /usr/bin/emulationstation

  boot_controls
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
                          "1)") kill_boot_controls
                                printf "\033c" > /dev/tty1
                                sudo systemctl restart ogage &
                                exit
                                ;;
                          "2)") kill_boot_controls
                                KillQuickMode
                                sudo systemctl restart ogage &
                                sudo systemctl restart firstboot &
                                sudo systemctl restart emulationstation
                                exit
                                ;;
                          "3)") kill_boot_controls
                                /opt/system/Wifi.sh
                                boot_controls
                                ;;
                          "4)") /opt/system/Enable\ Remote\ Services.sh 2>&1 > /dev/tty1
                                ;;
                          "5)") /opt/system/351Files.sh 2>&1 > /dev/tty1
                                ;;
                          "6)") kill_boot_controls
                                /opt/system/Advanced/"Backup ArkOS Settings.sh" 2>&1 > /dev/tty1
                                boot_controls
                                ;;
                          "7)") kill_boot_controls
                                /opt/system/Advanced/"Restore ArkOS Settings.sh" 2>&1 > /dev/tty1
                                boot_controls
                                ;;
                          "8)") sudo reboot
                                ;;
                          "9)") sudo shutdown now
                                ;;
                  esac
          done
  done
fi