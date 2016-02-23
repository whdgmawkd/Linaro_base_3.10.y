#!/bin/bash

export ARCH=arm
export CROSS_COMPILE=/home/dq/dev/UBERTC-arm-eabi-5.3/bin/arm-eabi-

TMPDIR=./build-files/tmp
CDATE=$(date +"%Y%m%d")
CDIR=$PWD
KERNEL_VERSION=$(grep -m 1 "CONFIG_LOCALVERSION" .config | sed s/\"//g)
KERNEL_VERSION=${KERNEL_VERSION##*-v}
KERNEL_NAME="PRIME_Kernel_v$KERNEL_VERSION.zip"
COMPRESS="gzip -9"

ADD_MODULES=1
RAMDISK_TW=./ramdisk/tw
RAMDISK_AOSP=./ramdisk/aosp
RAMDISK_TWRP=./ramdisk/twrp3
BUILD_VARIANTS="n916 n915 n910"
BUILD_AOSP=0
BUILD_TWRP=0

# echo "RAMDISK: $RAMDISK_TW"

function mtp_sec() {
    sed -i -e "s/# CONFIG_USB_ANDROID_SAMSUNG_MTP is not set/CONFIG_USB_ANDROID_SAMSUNG_MTP=y/g" .config
}
function mtp_nosec() {
    sed -i -e "s/CONFIG_USB_ANDROID_SAMSUNG_MTP=y/# CONFIG_USB_ANDROID_SAMSUNG_MTP is not set/g" .config
}

function n910c() {
	patch -p1 < utility/n910c.patch
}

function n910k() {
	patch -p1 < utility/n910k.patch
}

function ss300(){
    sed -i -e "s/CONFIG_UMTS_MODEM_SS333=y/# CONFIG_UMTS_MODEM_SS333 is not set/g" .config
    sed -i -e "s/# CONFIG_UMTS_MODEM_SS300 is not set/CONFIG_UMTS_MODEM_SS300=y/g" .config
    sed -i -e "s/CONFIG_SENSORHUB_S333=y/# CONFIG_SENSORHUB_S333 is not set/g" .config
    sed -i -e "s/import init.baseband-n916.rc/import init.baseband-n910.rc/g" $RAMDISK_TW/init.universal5433.rc 2>/dev/null
    sed -i -e "s/import init.baseband-n915.rc/import init.baseband-n910.rc/g" $RAMDISK_TW/init.universal5433.rc 2>/dev/null
    #sed -i -e "s/CONFIG_LINK_DEVICE_SPI=y/# CONFIG_LINK_DEVICE_SPI is not set/g" .config
}

function ss333(){
    sed -i -e "s/CONFIG_UMTS_MODEM_SS300=y/# CONFIG_UMTS_MODEM_SS300 is not set/g" .config
    sed -i -e "s/# CONFIG_UMTS_MODEM_SS333 is not set/CONFIG_UMTS_MODEM_SS333=y/g" .config
    sed -i -e "s/# CONFIG_SENSORHUB_S333 is not set/CONFIG_SENSORHUB_S333=y/g" .config
    sed -i -e "s/import init.baseband-n910.rc/import init.baseband-n916.rc/g" $RAMDISK_TW/init.universal5433.rc 2>/dev/null
    sed -i -e "s/import init.baseband-n915.rc/import init.baseband-n916.rc/g" $RAMDISK_TW/init.universal5433.rc 2>/dev/null
}

function flat(){
    sed -i -e "s/CONFIG_SENSORS_SSP_LPS25H=y/# CONFIG_SENSORS_SSP_LPS25H is not set/g" .config
    sed -i -e "s/CONFIG_LCD_ALPM=y/# CONFIG_LCD_ALPM is not set/g" .config
    sed -i -e "s/CONFIG_DECON_LCD_S6E3HF2=y/# CONFIG_DECON_LCD_S6E3HF2 is not set/g" .config
    sed -i -e "s/CONFIG_CAMERA_TBE=y/# CONFIG_CAMERA_TBE is not set/g" .config
    sed -i -e "s/# CONFIG_CAMERA_TRE is not set/CONFIG_CAMERA_TRE=y/g" .config
    sed -i -e "s/# CONFIG_KEYBOARD_CYPRESS_TOUCH_MBR31X5 is not set/CONFIG_KEYBOARD_CYPRESS_TOUCH_MBR31X5=y/g" .config
    sed -i -e "s/# CONFIG_DECON_LCD_S6E3HA2 is not set/CONFIG_DECON_LCD_S6E3HA2=y/g" .config
    sed -i -e "s/# CONFIG_SND_SAMSUNG_COMPENSATE_EXT_RES is not set/CONFIG_SND_SAMSUNG_COMPENSATE_EXT_RES=y/g" .config
    sed -i -e "s/# CONFIG_SENSORS_SSP_BMP182 is not set/CONFIG_SENSORS_SSP_BMP182=y/g" .config
}

function edge(){
    sed -i -e "s/# CONFIG_SENSORS_SSP_LPS25H is not set/CONFIG_SENSORS_SSP_LPS25H=y/g" .config
    sed -i -e "s/# CONFIG_LCD_ALPM is not set/CONFIG_LCD_ALPM=y/g" .config
    sed -i -e "s/# CONFIG_DECON_LCD_S6E3HF2 is not set/CONFIG_DECON_LCD_S6E3HF2=y/g" .config
    sed -i -e "s/# CONFIG_CAMERA_TBE is not set/CONFIG_CAMERA_TBE=y/g" .config
    sed -i -e "s/CONFIG_CAMERA_TRE=y/# CONFIG_CAMERA_TRE is not set/g" .config
    sed -i -e "s/CONFIG_KEYBOARD_CYPRESS_TOUCH_MBR31X5=y/# CONFIG_KEYBOARD_CYPRESS_TOUCH_MBR31X5 is not set/g" .config
    sed -i -e "s/CONFIG_DECON_LCD_S6E3HA2=y/# CONFIG_DECON_LCD_S6E3HA2 is not set/g" .config
    sed -i -e "s/CONFIG_SND_SAMSUNG_COMPENSATE_EXT_RES=y/# CONFIG_SND_SAMSUNG_COMPENSATE_EXT_RES is not set/g" .config
    sed -i -e "s/CONFIG_SENSORS_SSP_BMP182=y/# CONFIG_SENSORS_SSP_BMP182 is not set/g" .config
}

function mmc(){
    sed -i -e "s/# CONFIG_MMC_DW_BYPASS_FMP is not set/CONFIG_MMC_DW_BYPASS_FMP=y/g" .config
    sed -i -e "s/CONFIG_MMC_DW_FMP_DM_CRYPT=y/# CONFIG_MMC_DW_FMP_DM_CRYPT is not set/g" .config
}

function ufs1(){
    sed -i -e "s/CONFIG_MMC_DW_BYPASS_FMP=y/# CONFIG_MMC_DW_BYPASS_FMP is not set/g" .config
    sed -i -e "s/# CONFIG_MMC_DW_FMP_DM_CRYPT is not set/CONFIG_MMC_DW_FMP_DM_CRYPT=y/g" .config
}

function clean(){
	find ./drivers/sensorhub -name '*.o' -exec rm {} \;
	find ./drivers/misc/modem_v1 -name '*.o' -exec rm {} \;
}

function cleardir() {
    CDIR=$PWD
    cd $1

    find . -type f \( -iname \*.rej \
                    -o -iname \*.orig \
                    -o -iname \*.bkp \
                    -o -iname \*.ko \
                    -o -iname \*.c.BACKUP.[0-9]*.c \
                    -o -iname \*.c.BASE.[0-9]*.c \
                    -o -iname \*.c.LOCAL.[0-9]*.c \
                    -o -iname \*.c.REMOTE.[0-9]*.c \
                    -o -iname \*.org \
                    -o -iname \*.old \) \
                        | parallel --no-notice rm -fv {};

    rm -rf tmp/* > /dev/null 2>&1
    rm Module.symvers > /dev/null 2>&1
    rm .version > /dev/null 2>&1
    rm -R ./include/config > /dev/null 2>&1
    rm -R ./include/generated > /dev/null 2>&1
    rm -R ./arch/arm/include/generated > /dev/null 2>&1

    cd $CDIR
    chmod 644 $1/file_contexts > /dev/null 2>&1
    chmod 644 $1/se* > /dev/null 2>&1
    chmod 644 $1/*.rc > /dev/null 2>&1
    chmod 750 $1/init* > /dev/null 2>&1
    chmod 640 $1/fstab* > /dev/null 2>&1
    chmod 644 $1/default.prop > /dev/null 2>&1
    chmod 771 $1/data > /dev/null 2>&1
    chmod 755 $1/dev > /dev/null 2>&1
    chmod 755 $1/proc > /dev/null 2>&1
    chmod 750 $1/sbin > /dev/null 2>&1
    chmod 750 $1/sbin/* > /dev/null 2>&1
    chmod 755 $1/res > /dev/null 2>&1
    chmod 755 $1/res/* > /dev/null 2>&1
    chmod 755 $1/res/bin > /dev/null 2>&1
    chmod 755 $1/res/bin/* > /dev/null 2>&1
    chmod 755 $1/sys > /dev/null 2>&1
    chmod 755 $1/system > /dev/null 2>&1
}
