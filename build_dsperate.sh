#!/bin/bash

# Build and install DSperate standalone emulator
if [ -f "Arkbuild_package_cache/${CHIPSET}/dsperate.tar.gz" ] && [ "$(cat Arkbuild_package_cache/${CHIPSET}/dsperate.commit)" == "$(curl -s https://api.github.com/repos/beebono/DSperate/commits/main | jq -r '.sha')" ]; then
    sudo tar -xvzpf Arkbuild_package_cache/${CHIPSET}/dsperate.tar.gz
else
	call_chroot "cd /home/ark &&
	  cd ${CHIPSET}_core_builds &&
	  chmod 777 builds-alt.sh &&
	  eatmydata ./builds-alt.sh dsperate
	  "
	sudo mkdir -p Arkbuild/opt/DSperate/config
	sudo cp -a Arkbuild/home/ark/${CHIPSET}_core_builds/dsperate-64/dsperate Arkbuild/opt/DSperate/
	if [ -f "Arkbuild_package_cache/${CHIPSET}/dsperate.tar.gz" ]; then
	  sudo rm -f Arkbuild_package_cache/${CHIPSET}/dsperate.tar.gz
	fi
	if [ -f "Arkbuild_package_cache/${CHIPSET}/dsperate.commit" ]; then
	  sudo rm -f Arkbuild_package_cache/${CHIPSET}/dsperate.commit
	fi
	sudo tar -czpf Arkbuild_package_cache/${CHIPSET}/dsperate.tar.gz Arkbuild/opt/DSperate/
	sudo git --git-dir=Arkbuild/home/ark/${CHIPSET}_core_builds/DSperate/.git --work-tree=Arkbuild/home/ark/${CHIPSET}_core_builds/DSperate rev-parse HEAD > Arkbuild_package_cache/${CHIPSET}/dsperate.commit
fi
if [[ -e "DSperate/configs/dsperate.ini.$UNIT" ]]; then
  sudo cp -L DSperate/configs/dsperate.ini.${UNIT} Arkbuild/opt/DSperate/config/dsperate.ini
else
  sudo cp -L DSperate/configs/dsperate.ini.${CHIPSET} Arkbuild/opt/DSperate/config/dsperate.ini
fi
sudo cp -a DSperate/scripts/nds.sh Arkbuild/usr/local/bin/

call_chroot "chown -R ark:ark /opt/"
sudo chmod 777 Arkbuild/opt/DSperate/dsperate
sudo chmod 777 Arkbuild/usr/local/bin/nds.sh
