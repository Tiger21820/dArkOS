#!/bin/bash

# Build and install Mupen64Plus standalone emulator
sudo chroot Arkbuild/ bash -c "cd /home/ark &&
  cd rk3326_core_builds &&
  chmod 777 builds-alt.sh &&
  eatmydata ./builds-alt.sh mupen64plussa
  "
sudo mkdir -p Arkbuild/opt/mupen64plus
sudo mkdir -p Arkbuild/home/ark/.config/mupen64plus
sudo cp -a Arkbuild/home/ark/rk3326_core_builds/mupen64plussa-64/* Arkbuild/opt/mupen64plus/
sudo cp -a mupen64plus/configs/rgb10/mupen64plus.cfg Arkbuild/home/ark/.config/mupen64Plus/
sudo rm -f Arkbuild/opt/mupen64plus/*.gz
sudo cp -a mupen64plus/InputAutoCfg.ini Arkbuild/opt/mupen64Plus/
sudo cp mupen64plus/scripts/n64.sh Arkbuild/usr/local/bin/
sudo chroot Arkbuild/ bash -c "chown -R ark:ark /home/ark/.config/"
sudo chroot Arkbuild/ bash -c "chown -R ark:ark /opt/"
sudo chmod 777 Arkbuild/opt/mupen64plus/*
sudo chmod 777 Arkbuild/usr/local/bin/n64.sh
