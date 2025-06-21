#!/bin/bash

# Build and install ogage (Global Hotkey Daemon)
if [ "$CHIPSET" == "rk3326" ]; then
  branch="master"
elif [[ "$UNIT" == *"353"* ]]; then
  branch="rg353v"
fi
call_chroot "cd /home/ark &&
  git clone https://github.com/christianhaitian/ogage.git -b ${branch} &&
  cd ogage &&
  export CARGO_NET_GIT_FETCH_WITH_CLI=true &&
  cargo build --release &&
  strip target/release/ogage &&
  cp target/release/ogage /usr/local/bin/ &&
  chmod 777 /usr/local/bin/ogage
  "
sudo rm -rf Arkbuild/home/ark/ogage
sudo cp scripts/ogage.service Arkbuild/etc/systemd/system/ogage.service
call_chroot "systemctl enable ogage"
