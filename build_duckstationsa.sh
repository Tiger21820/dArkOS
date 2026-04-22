#!/bin/bash

sudo mkdir -p Arkbuild/opt/duckstation
sudo mkdir -p Arkbuild/home/ark/.local/share/duckstation
sudo cp duckstation/duckstation-sa-0.1-10495.AppImage Arkbuild/opt/duckstation/duckstationsa
sudo cp duckstation/scripts/standalone-duckstation Arkbuild/usr/local/bin/
sudo cp duckstation/configs/settings.ini.${UNIT} Arkbuild/home/ark/.local/share/duckstation/settings.ini
call_chroot "chown -R ark:ark /opt/"
call_chroot "chown -R ark:ark /home/ark/"
sudo chmod 777 Arkbuild/opt/duckstation/duckstationsa
sudo chmod 777 Arkbuild/usr/local/bin/standalone-duckstation
