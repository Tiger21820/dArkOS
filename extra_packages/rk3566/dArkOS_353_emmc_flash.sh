#!/bin/bash

export TERM=linux

if [ ! -z "$(df | grep mmcblk0)" ]; then
  msgbox "The internal emmc storage seems to be \
  mounted or you're running this tool from dArkOS \
  that is mounted on the internal emmc storage.  \
  Please make sure to run this tool from a sd card based \
  boot of dArkOS and make sure the internal storage is not \
  mounted prior to running this tool."
  exit
fi

if (( $(cat /sys/class/power_supply/battery/capacity) < 60 )); then
  msgbox "You have less than 60 percent battery life.  Please \
  charge your device to at least 60 percent battery life then \
  launch this tool again."
  exit
fi

msgbox "ONCE YOU PROCEED WITH THIS process, DO NOT STOP THIS PROCESS UNTIL IT IS COMPLETED \
OR YOUR INTERNAL EMMC MAY BE LEFT IN AN UNUSUABLE STATE.  This process will remove Android \
from your device and replace it with dArkOS.  You've been warned!  Type OK in the next \
screen to proceed."
my_var=`osk "Enter OK here to proceed." | tail -n 1`

if [ "$my_var" != "OK" ] && [ "$my_var" != "ok" ]; then
  sudo msgbox "You didn't type OK.  This process will exit now and no changes have been made from this process."
  exit
fi

if [ "$(cat ~/.config/.DEVICE)" = "RG353V" ]; then
  unit="353v"
elif [ "$(cat ~/.config/.DEVICE)" = "RG353M" ]; then
  unit="353m"
else
  msgbox "This doesn't seem to be a 353V or 353M unit."
  exit
fi

image=`find /roms/backup/ -iname "*$(cat ~/.config/.DEVICE)*" | head -n 1`
if [ -z "$image" ]; then
  image=`find /roms2/backup/ -iname "*$(cat ~/.config/.DEVICE)*" | head -n 1`
fi
if [ -z "$image" ]; then
  dialog --clear
  msgbox "An image to flash to your emmc couldn't be found. \
  Make you've copied one to your backup folder on your sd \
  card."
  exit
fi

dialog --clear
(pv -n "$image" | sudo dd of=/dev/mmcblk0 bs=1M status=none) 2>&1 | dialog --gauge "Writing the dArkOS \
image to emmc, please wait..." 10 50 0
dialog --clear
dialog --infobox "Updating some scripts and copying some settings to the linux partition of the internal \
emmc, please wait..." 10 50
olduuid=`blkid /dev/mmcblk0p4 | grep -oP ' UUID="\K[^"]+'`
sudo btrfstune -u -f /dev/mmcblk0p4
sudo mkdir -p /mnt/usbdrive
sudo mount /dev/mmcblk0p4 /mnt/usbdrive
# Update fstab to point to mmckblk0 for the vfat boot partition
sudo sed -i 's/mmcblk1/mmcblk0/' /mnt/usbdrive/etc/fstab
# Update switch to main sd script
sudo sed -i 's/mmcblk1/mmcblk0/' /mnt/usbdrive/usr/local/bin/Switch\ to\ Main\ SD\ for\ Roms.sh
# Fix light and deep sleep scripts
sudo sed -i 's/mmcblk1/mmcblk0/' /mnt/usbdrive/usr/local/bin/Sleep\ -\ Switch\ to\ *
sed -i 's/mmcblk1/mmcblk0/' /mnt/usbdrive/opt/system/Advanced/Sleep\ -\ Switch\ to\ *
# Copy some settings over that shouldn't intefere with the intial setup process
cp -f /home/ark/.config/panel_settings.txt /mnt/usbdrive/home/ark/.config/panel_settings.txt
if [ -f "/usr/local/bin/Kodi.sh" ]; then
  cp -Rf /home/ark/.kodi/* /mnt/usbdrive/home/ark/.kodi/
fi
cp -f /opt/drastic/config/drastic.cfg /mnt/usbdrive/opt/drastic/config/drastic.cfg 
cp -f /home/ark/.emulationstation/es_settings.cfg /mnt/usbdrive/home/ark/.emulationstation/es_settings.cfg
cp -Rf /home/ark/.emulationstation/collections/* /mnt/usbdrive/home/ark/.emulationstation/collections/
sudo cp -f /etc/localtime /mnt/usbdrive/etc/localtime
sudo cp -Rf /etc/NetworkManager/system-connections/* /mnt/usbdrive/etc/NetworkManager/system-connections/
sudo umount /mnt/usbdrive/
# Update uInitrd to point to mmcblk0p4 instead of mmcblk1p2
dialog --clear
dialog --infobox "Updating uInitrd in the boot partition of the internal emmc, please wait..." 10 50
sudo mount /dev/mmcblk0p3 /mnt/usbdrive
mkdir -p /dev/shm/initrd
cd /dev/shm/initrd
sudo sed -i '/COMPRESS\=/c\COMPRESS\=gzip' /etc/initramfs-tools/initramfs.conf
sudo update-initramfs -c -k "4.19.172" &> /dev/null
gunzip -c /boot/initrd.img-4.19.172 | cpio -idmv &> /dev/null
sed -i '/local dev_id\=/c\\tlocal dev_id\=\"/dev/mmcblk0p4\"' scripts/local
(find . | cpio -H newc -o | gzip -c > ../uInitrd) &> /dev/null
sudo mv -f ../uInitrd /mnt/usbdrive/uInitrd
sudo rm -f /boot/initrd.img-4.19.172
cd ..
rm -rf initrd
# Updated expandtoexfat script to point to mmcblk0
sudo sed -i 's/mmcblk1/mmcblk0/' /mnt/usbdrive/expandtoexfat.sh
# Updated fstab to point to mmckblk0 for vfat and exfat partitions
sudo sed -i 's/mmcblk1/mmcblk0/' /mnt/usbdrive/fstab.exfat
# Make sure backlight is set to match current backlight level after initialization
sudo sed -i "s/sudo rm -f \/boot\/fstab.exfat/sudo rm -f \/boot\/fstab.exfat\necho $(cat \/sys\/devices\/platform\/backlight\/backlight\/backlight\/brightness) \| sudo tee \/sys\/devices\/platform\/backlight\/backlight\/backlight\/brightness/" /mnt/usbdrive/expandtoexfat.sh
sudo umount /mnt/usbdrive/
dialog --clear
msgbox "Done.  Please reboot without a SD card in slot 1 to boot into dArkOS from emmc.  If you'd like to \
load Android back onto the internal memory, check out GammaOS-RK3566 by TheGammaSqueeze.  If you'd like to \
load the original stock Android OS, check out the GammaOS-RK3566 github page for information on how to \
reinstall the stock Android OS."