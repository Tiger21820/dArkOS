# <p align="center">Extra packages/features for use in dArkOS</p>

**Kodi-21.3-Omega-install.sh** - Kodi package available for install in an existing dArkOS installation for RK3566. Just copy it to your tools folder and launch from Options/Tools in the start menu.

**dArkOS_353_emmc_flash.sh** -  For RG353M and RG353V units, you can load dArkOS onto the internal (emmc) storage. Just copy it to your tools folder and launch from Options/Tools in the start menu.

**Notes**
- You must have at least 60 percent battery power available on your unit before the process can start. It is best to have it fully charged.
- You must be able to boot dArkOS from an existing sd card installation.
- You must have at least 8GBs of storage available on your roms partition. If you're using a 2 sd card setup, you must have at least 8GBs of free space on the 2nd sd card.
- This will not work with fat32 formatted sd cards due to the 4GB max singular file size limitation
- This is a fresh install of dArkOS onto your internal (emmc). Many settings and roms will not be transferred using this process except for the following:
  - Display Panel settings such as contrast and saturation
  - Kodi settings and plugins
  - Drastic emulator configuration
  - Most Emulationstation Settings (Some settings may need to be toggled such as preferred verbal warning voice and setting)
  - Wireless internet settings
- You should be able to do a backup and restore of your existing settings after the initial setup has been completed on your internal emmc storage.
- If you'd like to load Android back onto the internal memory, check out [GammaOS-RK3566](https://github.com/TheGammaSqueeze/GammaOS-RK3566) by TheGammaSqueeze.

Follow the instructions below:

1. Download the latest dArkOS image available from the [releases page](https://github.com/christianhaitian/dArkOS/releases) for your RG353M or RG353V.  Make sure to download both 7z.001 and 7z.002 files for the device
2. Using 7zip extract the .img file from the compressed file downloaded.  Make sure to do this from the 7z.001 file.
3. Place the extracted .img file into the backup folder of your sd card. If you're using a 2 sd card setup, you must place it in the 2nd sd card's backup folder.
4. Download this script and place it in the tools folder or your sd card. If you're using a 2 sd card setup, you must place it in the 2nd sd card's tool folder.
5. Boot dArkOS on your device then go to Options, Tools, then Press A on dArkOS_353_emmc_flash and follow the directions on the screen.