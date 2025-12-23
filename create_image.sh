#!/bin/bash

for IMAGE in *.img
do
  if [ ! -f ${IMAGE}.7z ] && [ ! -f ${IMAGE}.7z.001 ]; then
    7z a -v1950m ${IMAGE}.7z ${IMAGE}
    #xz --keep -z -9 -T0 -M 80% ${IMAGE}
  fi
done
