#!/bin/bash

ext="${1##*.}"
if [[ "$ext" == "png" ]] || [[ "$ext" == "PNG" ]]; then
  touch /dev/shm/PNG_Loaded
else
  rm /dev/shm/PNG_Loaded
fi
