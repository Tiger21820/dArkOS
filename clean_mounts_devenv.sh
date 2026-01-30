#!/bin/bash

function remove_ark_devenv() {
  for m in proc dev/pts dev dev sys
  do
    if grep -qs "Ark_devenv${bit}/${m} " /proc/mounts; then
      sudo umount -l Ark_devenv${bit}/${m}
      verify_action
      sync
      sleep 1
    fi
  done
  (cat /proc/mounts | grep -qs "Ark_devenv${bit}") && sudo umount -l Ark_devenv${bit}
  return 0
}

if [ "$1" == "32" ]; then
  bit="32"
else
  bit=""
fi

remove_ark_devenv
