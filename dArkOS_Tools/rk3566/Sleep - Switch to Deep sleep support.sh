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
sudo sed -i "/SuspendState\=/c\SuspendState\=mem" /etc/systemd/sleep.conf
cp -f /usr/local/bin/"Sleep - Switch to Light sleep support.sh" /opt/system/Advanced/.
sudo rm /opt/system/Advanced/"Sleep - Switch to Deep sleep support.sh"
sudo dd if=/usr/local/bin/uboot.img.anbernic of=/dev/mmcblk1 conv=notrunc bs=512 seek=16384
printf "\n\n\e[32mSleep mode has been switch to deep mode.  Restarting OS now...\n"
printf "\033[0m"
sleep 3
sudo reboot
