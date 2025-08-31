#!/bin/bash

# Delete the swapfile that was most like created by this script
# due to previous core core issues now resolved
if [ -f /swapfile ]; then
  test=$(stat -c %s "/swapfile")
  if [ "$test" = "400000000" ]; then
    sudo swapoff /swapfile
    sudo rm -f /swapfile
  fi
fi

#if [ ! -f /swapfile ]; then
#  min_space_mb=800
#  avail_space_mb=$(df -m | awk "\$6==\"/\" {print \$4}")
#  if [ "$avail_space_mb" -ge "$min_space_mb" ]; then
#    printf "\nCreating swapfile, please wait..." >> /dev/tty1
#    sudo dd if=/dev/zero of=/swapfile bs=1MB count=400
#    sudo chmod 600 /swapfile
#  else
#    printf "\nThere is not enough space on the root partition to create the" >> /dev/tty1
#    printf "\nlinux necessary swapfile for this retroarch core." >> /dev/tty1
#    sleep 5
#    clear >> /dev/tty1
#    exit 1
#  fi
#fi
#sudo mkswap /swapfile
#sudo swapon /swapfile

${1} -v -L /home/ark/.config/${1}/cores/${2}_libretro.so "${3}"
clear >> /dev/tty1
