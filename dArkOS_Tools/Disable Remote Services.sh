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
sudo systemctl disable NetworkManager-wait-online
sudo systemctl stop NetworkManager-wait-online
#sudo systemctl disable smbd.service
sudo timedatectl set-ntp 0
sudo systemctl stop smbd
sudo systemctl stop nmbd
#sudo systemctl disable nmbd.service
#sudo systemctl disable ssh
sudo systemctl stop ssh.service
sudo pkill filebrowser
printf "\n\n\n\e[32mRemote Services have been disabled.\n"
sleep 2