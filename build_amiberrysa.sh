#!/bin/bash

# Build and install Amiberry standalone emulator
if [ -f "Arkbuild_package_cache/${CHIPSET}/amiberrysa.tar.gz" ] && [ "$(cat Arkbuild_package_cache/${CHIPSET}/amiberrysa.commit)" == "$(curl -s https://raw.githubusercontent.com/christianhaitian/${CHIPSET}_core_builds/refs/heads/master/scripts/amiberry.sh | grep -oP '(?<=TAG=").*?(?=")')" ]; then
    sudo tar -xvzpf Arkbuild_package_cache/${CHIPSET}/amiberrysa.tar.gz
else
	call_chroot "cd /home/ark &&
	  cd ${CHIPSET}_core_builds &&
	  chmod 777 builds-alt.sh &&
	  eatmydata ./builds-alt.sh amiberry
	  "
	
	# Check if the chroot build succeeded
	if [ ! -d "Arkbuild/home/ark/${CHIPSET}_core_builds/amiberry64" ]; then
	  echo "ERROR: Amiberry build failed - amiberry64 directory not found"
	  exit 1
	fi
	
	sudo mkdir -p Arkbuild/opt/amiberry
	sudo cp -a Arkbuild/home/ark/${CHIPSET}_core_builds/amiberry64/* Arkbuild/opt/amiberry/
	if [ -f "Arkbuild_package_cache/${CHIPSET}/amiberrysa.tar.gz" ]; then
	  sudo rm -f Arkbuild_package_cache/${CHIPSET}/amiberrysa.tar.gz
	fi
	if [ -f "Arkbuild_package_cache/${CHIPSET}/amiberrysa.commit" ]; then
	  sudo rm -f Arkbuild_package_cache/${CHIPSET}/amiberrysa.commit
	fi
	sudo tar -czpf Arkbuild_package_cache/${CHIPSET}/amiberrysa.tar.gz Arkbuild/opt/amiberry/
	sudo curl -s https://raw.githubusercontent.com/christianhaitian/${CHIPSET}_core_builds/refs/heads/master/scripts/amiberry.sh | grep -oP '(?<=TAG=").*?(?=")' > Arkbuild_package_cache/${CHIPSET}/amiberrysa.commit
fi

# Ensure AmiBerry runtime dependencies are in the image
# (cache-only builds skip the chroot build step where amiberry.sh would install these)
call_chroot "apt-get -y install --no-install-recommends libserialport0 libportmidi0"

# Copy the wrapper script to /usr/local/bin
if [ -d "amiberry" ]; then
  sudo cp -a amiberry/amiberry* Arkbuild/usr/local/bin/
fi

call_chroot "chown -R ark:ark /opt/"
sudo chmod 777 Arkbuild/opt/amiberry/*
if ls Arkbuild/usr/local/bin/amiberry* 1> /dev/null 2>&1; then
  sudo chmod 777 Arkbuild/usr/local/bin/amiberry*
fi
