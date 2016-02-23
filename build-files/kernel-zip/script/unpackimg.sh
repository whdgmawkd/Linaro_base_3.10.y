#!/tmp/script/busybox sh

alias bb=/tmp/script/busybox
CURDIR=$PWD
cd /tmp

device_name=`getprop ro.bootloader|bb awk '{print tolower($0)}'`
device=${device_name:0:4}

bb tar -Jxf /tmp/bootimg.tar.xz $device-boot.img
bb dd of=/dev/block/mmcblk0p9 if=/tmp/$device-boot.img
rm bootimg.tar.xz

sync

echo " "
echo "DEVICE: $device"
echo "FILE  : $device-boot.img"
echo " "

cd $CURDIR
