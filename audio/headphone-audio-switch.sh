#!/bin/bash

CARD=0
isitminiloong=""

if [[ "$(cat /home/ark/.config/.DEVICE)" == "MINILOONG" ]]; then
   if [[ ! -e /sys/class/gpio/gpio16 ]]; then
      echo 16 > /sys/class/gpio/export
      echo out > /sys/class/gpio/gpio16/direction
   fi
   isitminiloong="y"
fi

if [[ "$(dmesg | grep 'headset status is ' | tail -1)" == *"headset status is in"* ]]; then
    amixer -c "$CARD" set 'Playback Path' 'HP'
    if [[ "${isitminiloong}" == "y" ]]; then
       echo 0 > /sys/class/gpio/gpio16/value
    fi
else
    amixer -c "$CARD" set 'Playback Path' 'SPK'
    if [[ "${isitminiloong}" == "y" ]]; then
       echo 1 > /sys/class/gpio/gpio16/value
    fi
fi