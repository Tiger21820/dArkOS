#!/bin/bash
printf "\033c" >> /dev/tty1
sudo cp /boot/rk3326-odroidgo2-linux-v11.dtb.oga11 /boot/rk3326-odroidgo2-linux-v11.dtb
cp -f -v /usr/local/bin/"Triggers -- Enable RGB10 Version.sh" /opt/system/Advanced/"Triggers -- Enable RGB10 Version.sh"
rm -f -v /opt/system/Advanced/"Triggers -- Enable OGA 1.1 Version.sh"
printf "\033c" >> /dev/tty1
printf "\n" >> /dev/tty1
printf "The Trigger (L2 and R2) buttons have been activated for the OGA 1.1.\nArkos will now be restarted." >> /dev/tty1
printf "\n" >> /dev/tty1
sleep 5
sudo reboot
