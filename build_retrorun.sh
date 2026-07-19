#!/bin/bash

# Build and install Retrorun and Retrorun32
if [ "$CHIPSET" == "rk3326" ]; then
  ext="-rk3326"
else
  ext="*"
fi

if [ -f "Arkbuild_package_cache/${CHIPSET}/retrorun.tar.gz" ] && [ "$(cat Arkbuild_package_cache/${CHIPSET}/retrorun.commit)" == "$(curl -s https://raw.githubusercontent.com/christianhaitian/${CHIPSET}_core_builds/refs/heads/master/scripts/retrorun.sh | grep -oP '(?<=commit=").*?(?=")')" ]; then
    sudo tar -xvzpf Arkbuild_package_cache/${CHIPSET}/retrorun.tar.gz
else
	call_chroot "cd /home/ark &&
	  if [ ! -d ${CHIPSET}_core_builds ]; then git clone https://github.com/christianhaitian/${CHIPSET}_core_builds.git; fi &&
	  cd ${CHIPSET}_core_builds &&
	  chmod 777 builds-alt.sh &&
	  ./builds-alt.sh retrorun
	  "
	sudo cp -a Arkbuild/home/ark/${CHIPSET}_core_builds/retrorun-64/retrorun${ext} Arkbuild/usr/local/bin/.
	if [ -f "Arkbuild_package_cache/${CHIPSET}/retrorun.tar.gz" ]; then
	  sudo rm -f Arkbuild_package_cache/${CHIPSET}/retrorun.tar.gz
	fi
	if [ -f "Arkbuild_package_cache/${CHIPSET}/retrorun.commit" ]; then
	  sudo rm -f Arkbuild_package_cache/${CHIPSET}/retrorun.commit
	fi
	sudo tar -czpf Arkbuild_package_cache/${CHIPSET}/retrorun.tar.gz Arkbuild/usr/local/bin/retrorun*
	sudo git --git-dir=Arkbuild/home/ark/${CHIPSET}_core_builds/retrorun/.git --work-tree=Arkbuild/home/ark/${CHIPSET}_core_builds/retrorun rev-parse HEAD > Arkbuild_package_cache/${CHIPSET}/retrorun.commit
fi
if [[ "${BUILD_ARMHF}" == "y" ]]; then
  if [ -f "Arkbuild_package_cache/${CHIPSET}/retrorun32.tar.gz" ] && [ "$(cat Arkbuild_package_cache/${CHIPSET}/retrorun32.commit)" == "$(curl -s https://raw.githubusercontent.com/christianhaitian/${CHIPSET}_core_builds/refs/heads/master/scripts/retrorun.sh | grep -oP '(?<=commit=").*?(?=")')" ]; then
    sudo tar -xvzpf Arkbuild_package_cache/${CHIPSET}/retrorun32.tar.gz
  else
	  call_chroot32 "cd /home/ark &&
		if [ ! -d ${CHIPSET}_core_builds ]; then git clone https://github.com/christianhaitian/${CHIPSET}_core_builds.git; fi &&
		cd ${CHIPSET}_core_builds &&
		chmod 777 builds-alt.sh &&
		./builds-alt.sh retrorun
		"
	  sudo cp -a Arkbuild32/home/ark/${CHIPSET}_core_builds/retrorun-32/retrorun32${ext} Arkbuild/usr/local/bin/.
	  if [ -f "Arkbuild_package_cache/${CHIPSET}/retrorun32.tar.gz" ]; then
	    sudo rm -f Arkbuild_package_cache/${CHIPSET}/retrorun32.tar.gz
	  fi
	  if [ -f "Arkbuild_package_cache/${CHIPSET}/retrorun32.commit" ]; then
	    sudo rm -f Arkbuild_package_cache/${CHIPSET}/retrorun32.commit
	  fi
	  sudo tar -czpf Arkbuild_package_cache/${CHIPSET}/retrorun32.tar.gz Arkbuild/usr/local/bin/retrorun32*
	  sudo git --git-dir=Arkbuild32/home/ark/${CHIPSET}_core_builds/retrorun/.git --work-tree=Arkbuild32/home/ark/${CHIPSET}_core_builds/retrorun rev-parse HEAD > Arkbuild_package_cache/${CHIPSET}/retrorun32.commit
  fi
fi

sudo cp retrorun/scripts/*.sh Arkbuild/usr/local/bin/
sudo cp retrorun/configs/retrorun.cfg.${CHIPSET} Arkbuild/home/ark/.config/retrorun.cfg

if [[ "$UNIT" == "miniloong" ]]; then
  sudo mv Arkbuild/usr/local/bin/retrorun-miniloong Arkbuild/usr/local/bin/retrorun
  if [[ "${BUILD_ARMHF}" == "y" ]]; then
    sudo mv Arkbuild/usr/local/bin/retrorun32-miniloong Arkbuild/usr/local/bin/retrorun32
  fi
else
  sudo rm Arkbuild/usr/local/bin/retrorun-miniloong
  if [[ "${BUILD_ARMHF}" == "y" ]]; then
    sudo rm Arkbuild/usr/local/bin/retrorun32-miniloong
  fi
fi
sudo chmod 777 Arkbuild/usr/local/bin/retrorun*
sudo chmod 777 Arkbuild/usr/local/bin/atomiswave.sh
sudo chmod 777 Arkbuild/usr/local/bin/dreamcast.sh
sudo chmod 777 Arkbuild/usr/local/bin/naomi.sh
sudo chmod 777 Arkbuild/usr/local/bin/saturn.sh
