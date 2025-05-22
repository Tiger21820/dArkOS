#!/bin/bash

echo -e "Installing build dependencies and needed packages...\n\n"

if [ "$1" == "32" ]; then
  BIT="32"
  ARCH="arm-linux-gnueabihf"
  CHROOT_DIR="Arkbuild32"
else
  BIT="64"
  ARCH="aarch64-linux-gnu"
  CHROOT_DIR="Arkbuild"
fi

# Install additional needed packages and protect them from autoremove
while read NEEDED_PACKAGE; do
  if [[ ! "$NEEDED_PACKAGE" =~ ^# ]]; then
    install_package $BIT "${NEEDED_PACKAGE}"
    protect_package $BIT "${NEEDED_PACKAGE}"
  fi
done <needed_packages.txt

# Install build dependencies
while read NEEDED_DEV_PACKAGE; do
  if [[ ! "$NEEDED_DEV_PACKAGE" =~ ^# ]]; then
    install_package $BIT "${NEEDED_DEV_PACKAGE}"
    protect_package $BIT "${NEEDED_DEV_PACKAGE}"
  fi
done <needed_dev_packages.txt

# Default gcc and g++ to version 12
#sudo chroot ${CHROOT_DIR}/ bash -c "update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 10"
#sudo chroot ${CHROOT_DIR}/ bash -c "update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 20"
#sudo chroot ${CHROOT_DIR}/ bash -c "update-alternatives --set gcc \"/usr/bin/gcc-12\""
#sudo chroot ${CHROOT_DIR}/ bash -c "update-alternatives --set g++ \"/usr/bin/g++-12\""

# Symlink ccache to chroot to speed up consecutive builds
sudo ln -s Arkbuild_ccache ${CHROOT_DIR}/home/ark/Arkbuild_ccache
sudo chroot ${CHROOT_DIR}/ bash -c "export CCACHE_DIR=/home/ark/Arkbuild_ccache"
sudo chroot ${CHROOT_DIR}/ bash -c "[ -z \$(echo \$PATH | grep Arkbuild_ccache) ] && export PATH=/home/ark/Arkbuild_ccache:\$PATH"

# Symlink fix for DRM headers
sudo chroot ${CHROOT_DIR}/ bash -c "ln -s /usr/include/libdrm/ /usr/include/drm"

# Install meson
sudo chroot ${CHROOT_DIR}/ bash -c "git clone https://github.com/mesonbuild/meson.git && ln -s /meson/meson.py /usr/bin/meson"

# Build and install librga
sudo chroot ${CHROOT_DIR}/ bash -c "cd /home/ark &&
  git clone https://github.com/christianhaitian/linux-rga.git &&
  cd linux-rga &&
  git checkout 1fc02d56d97041c86f01bc1284b7971c6098c5fb &&
  meson build && cd build &&
  meson compile &&
  cp -r librga.so* /usr/lib/${ARCH}/ &&
  cd .. &&
  mkdir -p /usr/local/include/rga &&
  cp -f drmrga.h rga.h RgaApi.h RockchipRgaMacro.h /usr/local/include/rga/
  "

# Build and install libgo2
sudo chroot ${CHROOT_DIR}/ bash -c "cd /home/ark &&
  git clone https://github.com/OtherCrashOverride/libgo2.git &&
  cd libgo2 &&
  premake4 gmake &&
  make -j$(nproc) &&
  cp libgo2.so* /usr/lib/${ARCH}/ &&
  mkdir -p /usr/include/go2 &&
  cp -L src/*.h /usr/include/go2/
  "
