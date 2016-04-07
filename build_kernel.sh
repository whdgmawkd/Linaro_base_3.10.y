#!/bin/bash

source ./set_env.sh

rm $TMPDIR/* 2> /dev/null
cleardir
#make clean

echo ""
rm .version 2>/dev/null

if [ $BUILD_A8_TW -eq 1 ]; then
	cleardir $RAMDISK_TW
    echo ""
    echo "------------------------ SM-A800S TW ----------------------------"
    mtp_sec && make -j4
    ./utility/mkbootfs $RAMDISK_TW | $COMPRESS > $TMPDIR/ramdisk.img
    ./utility/mkbootimg --base 0x10000000 --pagesize 2048 --kernel ./arch/arm/boot/zImage --ramdisk $TMPDIR/ramdisk.img --dt ./utility/$DTB -o $TMPDIR/a8tw-boot.img
    echo -n "SEANDROIDENFORCE" >> $TMPDIR/a8tw-boot.img
fi

if [ $ADD_MODULES -eq 1 ]; then
	for i in $(find ./ -name '*.ko'); do
		cp -av "$i" ./build-files/kernel-zip/system/lib/modules/ >/dev/null 2>&1
		rm -f "$i" >/dev/null 2>&1
		echo $i
	done;
fi

if [ $BUILD_A8_TWRP -eq 1 ]; then
    TWRP=./twrp3
	cleardir $TWRP
    echo ""
    echo "---------------------- build TWRP -----------------------"
    mtp_nosec && make -j4
    ./utility/mkbootfs $TWRP | $COMPRESS > $TMPDIR/ramdisk.img
    ./utility/mkbootimg --base 0x10000000 --pagesize 2048 --kernel ./arch/arm/boot/zImage --ramdisk $TMPDIR/ramdisk.img --dt ./utility/$DTB -o $TMPDIR/recovery.img
    echo -n "SEANDROIDENFORCE" >> $TMPDIR/recovery.img
    cd $TMPDIR && tar -cvf twrp-3.0.0.0-$CDATE-a8elte.tar recovery.img >/dev/null 2>&1 && cd $CDIR
    mv -f $TMPDIR/twrp-3.0.0.0-$CDATE-a8elte.tar ../HostPC/Kernel/
    mtp_sec
fi

cd $TMPDIR
tar -cvf bootimg.tar a8*-boot.img
xz -z -9 bootimg.tar
mv -f bootimg.tar.xz ../kernel-zip/bootimg.tar.xz
cd ../kernel-zip
rm $KERNEL_NAME
rm ../../../HostPC/Kernel/out/$KERNEL_NAME
7z a -mx9 $KERNEL_NAME *
zipalign -v 4 $KERNEL_NAME ../../../HostPC/Kernel/out/$KERNEL_NAME
rm bootimg.tar.xz
rm $KERNEL_NAME
cd $CDIR
rm $TMPDIR/* 2> /dev/null
echo ""
echo "------------------------   DONE!!   ----------------------------"
echo ""
