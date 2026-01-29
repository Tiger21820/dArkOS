#!/bin/bash

# Build and install gametank
if [ -f "Arkbuild_package_cache/${CHIPSET}/gametank.tar.gz" ] && [ "$(cat Arkbuild_package_cache/${CHIPSET}/gametank.commit)" == "$(curl -s https://api.github.com/repos/clydeshaffer/gametankemulator/commits/main | jq -r '.sha')" ]; then
    sudo tar -xvzpf Arkbuild_package_cache/${CHIPSET}/gametank.tar.gz
else
	call_chroot "cd /home/ark &&
	  cd ${CHIPSET}_core_builds &&
	  chmod 777 builds-alt.sh &&
	  ./builds-alt.sh gametank
	  "
	sudo mkdir -p Arkbuild/opt/gametank
	sudo cp -a Arkbuild/home/ark/${CHIPSET}_core_builds/gametank64/GameTankEmulator Arkbuild/opt/gametank/
	if [ -f "Arkbuild_package_cache/${CHIPSET}/gametank.tar.gz" ]; then
	  sudo rm -f Arkbuild_package_cache/${CHIPSET}/gametank.tar.gz
	fi
	if [ -f "Arkbuild_package_cache/${CHIPSET}/gametank.commit" ]; then
	  sudo rm -f Arkbuild_package_cache/${CHIPSET}/gametank.commit
	fi
	sudo tar -czpf Arkbuild_package_cache/${CHIPSET}/gametank.tar.gz Arkbuild/opt/gametank/
	sudo curl -s https://api.github.com/repos/clydeshaffer/gametankemulator/commits/main | jq -r '.sha' > Arkbuild_package_cache/${CHIPSET}/gametank.commit
fi
sudo cp gametank/config/gametank.gptk Arkbuild/opt/gametank/gametank.gptk
sudo cp gametank/scripts/gametank.sh Arkbuild/usr/local/bin/

call_chroot "chown -R ark:ark /opt/"
sudo chmod 777 Arkbuild/opt/gametank/GameTankEmulator
sudo chmod 777 Arkbuild/usr/local/bin/gametank.sh

