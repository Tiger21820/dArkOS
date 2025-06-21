#!/bin/bash

# Build and install Mednafen
call_chroot "cd /home/ark &&
  cd ${CHIPSET}_core_builds &&
  chmod 777 builds-alt.sh &&
  ./builds-alt.sh mednafen
  "
sudo mkdir -p Arkbuild/opt/mednafen
sudo mkdir -p Arkbuild/home/ark/.mednafen
sudo cp -a Arkbuild/home/ark/${CHIPSET}_core_builds/mednafen64/mednafen Arkbuild/opt/mednafen/
sudo cp -a mednafen/configs/mednafen.cfg.${UNIT} Arkbuild/home/ark/.mednafen/mednafen.cfg
sudo cp -a mednafen/mednafen Arkbuild/usr/local/bin/

call_chroot "chown -R ark:ark /home/ark/.mednafen/"
call_chroot "chown -R ark:ark /opt/"
sudo chmod 777 Arkbuild/opt/mednafen/mednafen
sudo chmod 777 Arkbuild/usr/local/bin/mednafen

