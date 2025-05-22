#!/bin/bash

# Build and install XRoar
sudo chroot Arkbuild/ bash -c "cd /home/ark &&
  cd rk3326_core_builds &&
  chmod 777 builds-alt.sh &&
  ./builds-alt.sh xroar
  "
sudo mkdir -p Arkbuild/opt/xroar
sudo cp -a Arkbuild/home/ark/rk3326_core_builds/xroar64/xroar Arkbuild/opt/xroar/
sudo cp -a xroar/coco.sh Arkbuild/usr/local/bin/
sudo cp -Ra xroar/controls/ Arkbuild/opt/xroar/
sudo cp -a xroar/xroar.gptk Arkbuild/opt/xroar/

sudo chroot Arkbuild/ bash -c "chown -R ark:ark /opt/"
sudo chmod 777 Arkbuild/opt/xroar/xroar
sudo chmod 777 Arkbuild/usr/local/bin/coco.sh

