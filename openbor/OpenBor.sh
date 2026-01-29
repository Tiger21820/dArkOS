#!/bin/sh
echo "VAR=OpenBOR" > /home/ark/.config/KILLIT
sudo systemctl restart killer_daemon.service
#cp "$1" /opt/OpenBor/Paks
file="$1"
basefile=$(basename -- "$file")
basefilename=${basefile%.*}
ln -s "$1" /opt/OpenBor/Paks/"$basefile"
if [ ! -f "/opt/OpenBor/Saves/${basefilename}.cfg" ]; then
  cp "/opt/OpenBor/Saves/master.cfg" "/opt/OpenBor/Saves/${basefilename}.cfg"
fi
cd /opt/OpenBor/
./OpenBOR
#LD_LIBRARY_PATH=. ./OpenBOR
rm -rf /opt/OpenBor/Paks/*
sudo systemctl stop killer_daemon.service
printf "\033c" >> /dev/tty1
