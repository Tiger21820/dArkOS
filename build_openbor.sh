#!/bin/bash

# Build and install OpenBOR standalone emulator
call_chroot "cd /home/ark &&
  cd ${CHIPSET}_core_builds &&
  chmod 777 builds-alt.sh &&
  eatmydata ./builds-alt.sh openbor
  "
sudo mkdir -p Arkbuild/opt/OpenBOR
sudo mkdir -p Arkbuild/opt/OpenBOR/Paks
sudo mkdir -p Arkbuild/opt/OpenBOR/Saves
sudo cp -a Arkbuild/home/ark/${CHIPSET}_core_builds/openbor-64/OpenBOR Arkbuild/opt/OpenBOR/
sudo cp -a openbor/configs/master.cfg.${UNIT} Arkbuild/opt/OpenBOR/Saves/
sudo cp openbor/OpenBOR.sh Arkbuild/opt/OpenBOR/OpenBOR.sh
call_chroot "chown -R ark:ark /opt/"
sudo chmod 777 Arkbuild/opt/OpenBOR/OpenBOR.sh
