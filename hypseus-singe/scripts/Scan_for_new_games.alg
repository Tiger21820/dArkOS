#!/bin/bash

for f in /roms/alg/*/; do
  if [ -d "$f" ]; then
    basefilename=$(basename "$f")

    if [[ ! -f "$f/${basefilename,,}.alg" ]] && [[ ! -f "$f/${basefilename,,}.ALG" ]] && [[ ! "$basefilename" = "images" ]]; then
      touch "/roms/alg/${basefilename}.alg"
      printf "\nFound $basefilename and created ES menu shortcut for it" >> /dev/tty1
    fi
  fi
done
