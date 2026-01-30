#!/bin/bash

if [[ $1 == "standalone" ]]; then
  /usr/local/bin/amiberry.sh "$2"
else
  if [[ ! -e "/usr/lib/arm-linux-gnueabihf/libFLAC.so.8" ]]; then
    sudo ln -sf $(find /usr/lib/arm-linux-gnueabihf/ -name libFLAC.so.12.*) /usr/lib/arm-linux-gnueabihf/libFLAC.so.8
  fi
  if [[ ! -e "/usr/lib/aarch64-linux-gnu/libFLAC.so.8" ]]; then
    sudo ln -sf $(find /usr/lib/aarch64-linux-gnu/ -name libFLAC.so.12.*) /usr/lib/aarch64-linux-gnu/libFLAC.so.8
  fi
  /usr/local/bin/"$1" -L /home/ark/.config/"$1"/cores/"$2"_libretro.so "$3"
fi