#!/bin/bash

# Build and install flycast standalone emulator
if [ -f "Arkbuild_package_cache/${CHIPSET}/flycastsa.tar.gz" ] && [ "$(cat Arkbuild_package_cache/${CHIPSET}/flycastsa.commit)" == "$(curl -s https://raw.githubusercontent.com/christianhaitian/${CHIPSET}_core_builds/refs/heads/master/scripts/flycastsa.sh | grep -oP '(?<=TAG=").*?(?=")')" ]; then
    sudo tar -xvzpf Arkbuild_package_cache/${CHIPSET}/flycastsa.tar.gz
else
	call_chroot "cd /home/ark &&
	  cd ${CHIPSET}_core_builds &&
	  chmod 777 builds-alt.sh &&
	  eatmydata ./builds-alt.sh flycastsa
	  "
	sudo mkdir -p Arkbuild/opt/flycastsa
	if [[ "$CHIPSET" = "rk3326" ]]; then
	  ext="-rk3326"
	else
	  ext=""
	fi
	sudo cp -R Arkbuild/home/ark/${CHIPSET}_core_builds/flycastsa-64/flycast${ext} Arkbuild/opt/flycastsa/flycast
	if [ -f "Arkbuild_package_cache/${CHIPSET}/flycastsa.tar.gz" ]; then
	  sudo rm -f Arkbuild_package_cache/${CHIPSET}/flycastsa.tar.gz
	fi
	if [ -f "Arkbuild_package_cache/${CHIPSET}/flycastsa.commit" ]; then
	  sudo rm -f Arkbuild_package_cache/${CHIPSET}/flycastsa.commit
	fi
	sudo tar -czpf Arkbuild_package_cache/${CHIPSET}/flycastsa.tar.gz Arkbuild/opt/flycastsa/
	sudo curl -s https://raw.githubusercontent.com/christianhaitian/${CHIPSET}_core_builds/refs/heads/master/scripts/flycastsa.sh | grep -oP '(?<=TAG=").*?(?=")' > Arkbuild_package_cache/${CHIPSET}/flycastsa.commit
fi

sudo mkdir -p Arkbuild/home/ark/.config/flycast
sudo cp flycast/config/emu.cfg Arkbuild/home/ark/.config/flycast/
call_chroot "chown -R ark:ark /opt/"
call_chroot "chown -R ark:ark /home/ark/.config/flycast/"
sudo chmod 777 Arkbuild/opt/flycastsa/flycast
