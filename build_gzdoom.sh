#!/bin/bash

# Build and install gzdoom standalone emulator
call_chroot "cd /home/ark &&
  cd ${CHIPSET}_core_builds &&
  chmod 777 builds-alt.sh &&
  eatmydata ./builds-alt.sh gzdoom
  "
sudo mkdir -p Arkbuild/opt/gzdoom
sudo mkdir -p Arkbuild/home/ark/.config/gzdoom
sudo cp -a Arkbuild/home/ark/${CHIPSET}_core_builds/gzdoom64/gzdoom Arkbuild/opt/gzdoom/
sudo cp -a Arkbuild/home/ark/${CHIPSET}_core_builds/zmusic/build/source/libzmusic.so.* Arkbuild/opt/gzdoom/
sudo cp -a Arkbuild/lib/aarch64-linux-gnu/libvpx.so.*[2-9] Arkbuild/opt/gzdoom/
sudo cp -a Arkbuild/usr/lib/aarch64-linux-gnu/libwebpdemux.so.*[2-9] Arkbuild/opt/gzdoom/
sudo cp -a Arkbuild/home/ark/${CHIPSET}_core_builds/gzdoom64/*.pk3 Arkbuild/home/ark/.config/gzdoom/
sudo cp -R Arkbuild/home/ark/${CHIPSET}_core_builds/gzdoom/fm_banks/ Arkbuild/home/ark/.config/gzdoom/
sudo cp -R Arkbuild/home/ark/${CHIPSET}_core_builds/gzdoom/soundfont/ Arkbuild/home/ark/.config/gzdoom/
sudo cp -a gzdoom/configs/${UNIT}/gzdoom.ini Arkbuild/home/ark/.config/gzdoom/
sudo cp gzdoom/scripts/doom* Arkbuild/usr/local/bin/
sudo cp -R gzdoom/backup/ Arkbuild/home/ark/.config/gzdoom/
call_chroot "chown -R ark:ark /home/ark/.config/"
call_chroot "chown -R ark:ark /opt/"
sudo chmod 777 Arkbuild/opt/gzdoom/*
sudo chmod 777 Arkbuild/usr/local/bin/doom*
