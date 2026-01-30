#!/bin/bash
if compgen -G "/boot/rk3566*" > /dev/null; then
  if test ! -z "$(cat /home/ark/.config/.DEVICE | grep RGB20PRO | tr -d '\0')"
  then
    sudo setfont /usr/share/consolefonts/Lat7-TerminusBold32x16.psf.gz
  else
    sudo setfont /usr/share/consolefonts/Lat7-TerminusBold28x14.psf.gz
  fi
  height="20"
  width="60"
fi
sudo systemctl enable NetworkManager-wait-online
sudo systemctl start NetworkManager-wait-online
GW=`ip route | awk '/default/ { print $3 }'`
if [ ! -z "$GW" ]; then
  printf "\n\n\e[32mEnabling Remote Services.  Please wait...\n"																
  #sudo systemctl enable smbd.service
  sudo timedatectl set-ntp 1 &
  sudo systemctl start smbd
  sudo systemctl start nmbd
  #sudo systemctl enable nmbd
  #sudo systemctl enable ssh
  sudo systemctl start ssh.service
  sudo filebrowser -a 0.0.0.0 -p 80 -d /home/ark/.config/filebrowser.db -r / &
  printf "\n\n\n\e[32mRemote Services have been enabled.\n"
  printf "Your IP is: " && ip route | awk '/src/ { print $9 }' && printf "\n\n"
  sleep 5
else
  printf "\n\n\n\e[91mYour network connection doesn't seem to be working.  Did you make sure to configure your wifi connection using the Wifi selection in the Options menu?\n"
  sleep 5
fi
