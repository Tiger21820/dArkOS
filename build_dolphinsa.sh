#!/bin/bash

# Build and install Dolphin standalone emulator
if [ -f "Arkbuild_package_cache/${CHIPSET}/dolphinsa.tar.gz" ] && [ "$(cat Arkbuild_package_cache/${CHIPSET}/dolphinsa.commit)" == "$(curl -s https://raw.githubusercontent.com/christianhaitian/${CHIPSET}_core_builds/refs/heads/master/scripts/dolphinsa.sh | grep -oP '(?<=TAG=").*?(?=")')" ]; then
    sudo tar -xvzpf Arkbuild_package_cache/${CHIPSET}/dolphinsa.tar.gz
else
	call_chroot "cd /home/ark &&
	  cd ${CHIPSET}_core_builds &&
	  chmod 777 builds-alt.sh &&
	  eatmydata ./builds-alt.sh dolphinsa
	  "
	sudo mkdir -p Arkbuild/opt/dolphin
	sudo mkdir -p Arkbuild/home/ark/.local/share/dolphin-emu
	sudo cp -Ra Arkbuild/home/ark/${CHIPSET}_core_builds/dolphinsa64/dolphin-emu-nogui Arkbuild/opt/dolphin/
	sudo cp -Ra Arkbuild/home/ark/${CHIPSET}_core_builds/dolphin/Data/Sys/* Arkbuild/home/ark/.local/share/dolphin-emu/
	if [ -f "Arkbuild_package_cache/${CHIPSET}/dolphinsa.tar.gz" ]; then
	  sudo rm -f Arkbuild_package_cache/${CHIPSET}/dolphinsa.tar.gz
	fi
	if [ -f "Arkbuild_package_cache/${CHIPSET}/dolphinsa.commit" ]; then
	  sudo rm -f Arkbuild_package_cache/${CHIPSET}/dolphinsa.commit
	fi
	sudo tar -czpf Arkbuild_package_cache/${CHIPSET}/dolphinsa.tar.gz Arkbuild/opt/dolphin/ Arkbuild/home/ark/.local/share/dolphin-emu/
	sudo curl -s https://raw.githubusercontent.com/christianhaitian/${CHIPSET}_core_builds/refs/heads/master/scripts/dolphinsa.sh | grep -oP '(?<=TAG=").*?(?=")' > Arkbuild_package_cache/${CHIPSET}/dolphinsa.commit
fi
sudo cp -R dolphin/Config/ Arkbuild/home/ark/.local/share/dolphin-emu/
sudo cp dolphin/scripts/dolphin.sh Arkbuild/usr/local/bin/
call_chroot "chown -R ark:ark /opt/"
call_chroot "chown -R ark:ark /home/ark/"
sudo chmod 777 Arkbuild/opt/dolphin/dolphin-emu-nogui
sudo chmod 777 Arkbuild/usr/local/bin/dolphin.sh
