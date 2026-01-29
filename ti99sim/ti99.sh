#!/bin/bash
directory=$(dirname "$1" | cut -d "/" -f2)
echo "VAR=ti99sim-sdl" > /home/ark/.config/KILLIT
sudo systemctl restart killer_daemon.service
cd /opt/ti99sim/bin
./ti99sim-sdl -f --console=/$directory/bios/ti-994a.ctg "$1"
sudo systemctl stop killer_daemon.service