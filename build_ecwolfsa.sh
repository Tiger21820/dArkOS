#!/bin/bash

# Build and install ECWolf standalone emulator
call_chroot "cd /home/ark &&
  cd ${CHIPSET}_core_builds &&
  chmod 777 builds-alt.sh &&
  eatmydata ./builds-alt.sh ecwolfsa
  "
sudo mkdir -p Arkbuild/opt/ecwolf
sudo mkdir -p Arkbuild/home/ark/.config/ecwolf
sudo cp -a Arkbuild/home/ark/${CHIPSET}_core_builds/ecwolf-64/* Arkbuild/opt/ecwolf/
sudo cp -a ecwolf/config/ecwolf.cfg.${UNIT} Arkbuild/home/ark/.config/ecwolf/ecwolf.cfg
sudo cp -a ecwolf/ecwolf* Arkbuild/usr/local/bin/

call_chroot "chown -R ark:ark /home/ark/.config/"
call_chroot "chown -R ark:ark /opt/"
sudo chmod 777 Arkbuild/opt/ecwolf/*
sudo chmod 777 Arkbuild/usr/local/bin/ecwolf*
