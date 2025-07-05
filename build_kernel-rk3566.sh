#!/bin/bash

# Build and install custom kernel from christianhaitian/linux
KERNEL_SRC=main
if [ ! -d "$KERNEL_SRC" ]; then
  git clone --recursive --depth=1 https://github.com/christianhaitian/RG353VKernel.git $KERNEL_SRC
fi
cd $KERNEL_SRC
make ARCH=arm64 rk3566_optimized_linux_defconfig
CFLAGS=-Wno-deprecated-declarations make -j$(nproc) ARCH=arm64 KERNEL_DTS=rk3566 KERNEL_CONFIG=rk3566_optimized_linux_defconfig
#CFLAGS=-Wno-deprecated-declarations make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules_prepare
#CFLAGS=-Wno-deprecated-declarations make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image dtbs modules
verify_action
cd ..

# Install kernel modules
sudo make -C $KERNEL_SRC ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=../Arkbuild modules_install

# Format boot partition
#BOOT_PART_OFFSET=$((SYSTEM_PART_START * 512))
#BOOT_PART_SIZE=$(( (SYSTEM_PART_END - SYSTEM_PART_START + 1) * 512 ))
#LOOP_BOOT=$(sudo losetup --find --show --offset ${BOOT_PART_OFFSET} --sizelimit ${BOOT_PART_SIZE} ${DISK})
#sudo mkfs.vfat -F 32 -n BOOT ${LOOP_BOOT}
mountpoint=mnt/boot
mkdir -p ${mountpoint}
sudo mount ${LOOP_DEV}p3 ${mountpoint}

# Copy kernel, device tree, and modules into target rootfs
KERNEL_VERSION=$(basename $(ls Arkbuild/lib/modules))
sudo cp $KERNEL_SRC/.config Arkbuild/boot/config-${KERNEL_VERSION}
sudo cp $KERNEL_SRC/arch/arm64/boot/Image ${mountpoint}/
sudo cp $KERNEL_SRC/arch/arm64/boot/dts/rockchip/${UNIT_DTB}.dtb ${mountpoint}/

# Create uInitrd from generated initramfs
#sudo cp /usr/bin/qemu-aarch64-static Arkbuild/usr/bin/
KERNEL_VERSION=$(basename $(find Arkbuild/lib/modules -maxdepth 1 -mindepth 1 -type d))
# Create symlink so depmod/initramfs can find modules for uname -r (host kernel)
sudo touch Arkbuild/lib/modules/${KERNEL_VERSION}/modules.builtin.modinfo
call_chroot "uname() { echo ${KERNEL_VERSION}; }; export -f uname; depmod ${KERNEL_VERSION}; update-initramfs -c -k ${KERNEL_VERSION}"
#sudo rm Arkbuild/usr/bin/qemu-aarch64-static
sudo cp Arkbuild/boot/initrd.img-* ${mountpoint}/initrd.img
if ! command -v mkimage &> /dev/null; then
  sudo apt -y update
  sudo apt -y install u-boot-tools
fi
mkdir initrd

#Update uInitrd to force booting from mmcblk1p4
sudo mv ${mountpoint}/initrd.img initrd/.
cd initrd
gunzip -c initrd.img | cpio -idmv
rm -f initrd.img
sed -i '/local dev_id\=/c\\tlocal dev_id\=\"/dev/mmcblk1p4\"' scripts/local
#Add regulatory.db and regualtory.db.p7s
mkdir -p usr/lib/firmware
wget https://github.com/CaffeeLake/wireless-regdb/raw/refs/heads/master/regulatory.db -O lib/firmware/regulatory.db -O lib/firmware/regulatory.db
#wget -t 5 -T 60 https://git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git/plain/regulatory.db.p7s -O lib/firmware/regulatory.db.p7s
find . | cpio -H newc -o | gzip -c > ../uInitrd
sudo mv ../uInitrd ../${mountpoint}/uInitrd
cd ..
rm -rf initrd
sudo rm -f ${mountpoint}/initrd.img

# Build uboot and resource and install it to the image
cd $KERNEL_SRC
cp arch/arm64/boot/dts/rockchip/${UNIT_DTB}.dtb .
# Next line generates the resource.img file needed to flash to the image and to build the uboot
scripts/mkimg --dtb ${UNIT_DTB}.dtb
git clone --depth=1 https://github.com/christianhaitian/rk356x-uboot.git
git clone https://github.com/christianhaitian/rkbin.git
mkdir -p ./prebuilts/gcc/linux-x86/aarch64/
ln -s /opt/toolchains/gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu ./prebuilts/gcc/linux-x86/aarch64/gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu
cd rk356x-uboot
cp ../resource.img rk3566_tool/Image/
./make.sh rk3566

echo "Flashing uboot.img and resource.img..."
sudo cp uboot.img ../../Arkbuild/usr/local/bin/uboot.img.jelos
sudo dd if=uboot.img of=$LOOP_DEV bs=$SECTOR_SIZE seek=16384 conv=notrunc
sudo dd if=rk3566_tool/Image/resource.img of=$LOOP_DEV bs=$SECTOR_SIZE seek=24576 conv=notrunc
#sudo dd if=device/rk3566/uboot.img of=$LOOP_DEV bs=$SECTOR_SIZE seek=16384 conv=notrunc
#sudo dd if=device/rk3566/resource.img of=$LOOP_DEV bs=$SECTOR_SIZE seek=24576 conv=notrunc
cd ../..
