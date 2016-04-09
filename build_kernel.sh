#!/bin/bash

source ./set_env.sh
rm $TMPDIR/* 2> /dev/null
rm .version 2>/dev/null
mtp_sec
cleardir > /dev/null 2>&1

for VARIANT in $BUILD_VARIANTS
do
	echo ""
	echo "------------------------ build $VARIANT zImage ----------------------------"
	echo ""
    case $VARIANT in
      n916)
        ufs1 && flat && ss333 && clean
        BOARD="SYSMAGIC001K"
    	DTB="n916s-boot.img-dtb"
      ;;
      n915)
    	mmc && edge && ss300 && clean
        BOARD="SYSMAGIC000K"
		DTS="exynos5433-tbelte_kor_open_14.dtb"
		DTB="n915-dt.img"
      ;;
      n910)
    	mmc && flat && ss300 && clean
        BOARD="SYSMAGIC000K"
		DTS="exynos5433-trelte_kor_open_12.dtb"
		DTB="n910-dt.img"
      ;;
    esac

	if [ $VARIANT != "n916" ]; then
		echo "* buid dtb *"
		rm ./arch/arm/boot/dts/*.dtb 2>/dev/null
		make $DTS
		./utility/dtbtool -o ./utility/$DTB -s 2048 -p ./scripts/dtc/ ./arch/arm/boot/dts/
	fi

    make -j4
	./utility/mkbootfs $RAMDISK_TW | $COMPRESS > ./utility/ramdisk-tw.img

	cp -f ./arch/arm/boot/zImage ./utility/${VARIANT}-zImage
	./utility/mkbootimg --base 0x10000000 --pagesize 2048 --board $BOARD --kernel ./utility/${VARIANT}-zImage --ramdisk ./utility/ramdisk-tw.img --dt ./utility/$DTB -o $TMPDIR/${VARIANT}-boot.img
	echo -n "SEANDROIDENFORCE" >> $TMPDIR/${VARIANT}-boot.img
	cp -f  $TMPDIR/${VARIANT}-boot.img ../HostPC/Kernel/${VARIANT}-boot.img

    if [ $BUILD_TWRP -eq 1 ] ||  [ $BUILD_AOSP -eq 1 ]; then
        mtp_nosec
        make -j4
        mtp_sec
    fi

    if [ $BUILD_TWRP -eq 1 ]; then
        echo ""
    	echo "------------------------ build $VARIANT TWRP ----------------------------"
		./utility/mkbootfs $RAMDISK_TWRP | $COMPRESS > ./utility/ramdisk-twrp.img
	    cp -f ./arch/arm/boot/zImage ./utility/${VARIANT}-recovery-zImage
        ./utility/mkbootimg --base 0x10000000 --pagesize 2048 --board $BOARD --kernel ./utility/${VARIANT}-recovery-zImage --ramdisk ./utility/ramdisk-twrp.img --dt ./utility/$DTB -o ./utility/recovery.img
        echo -n "SEANDROIDENFORCE" >> ./utility/recovery.img
        cd utility && tar -cvf twrp-3.0.0.0-$CDATE-${VARIANT}.tar recovery.img >/dev/null 2>&1 && cd ..
        cp -f ./utility/recovery.img ../HostPC/Kernel/${VARIANT}-recovery.img
        mv -f ./utility/twrp-3.0.0.0-$CDATE-${VARIANT}.tar ../HostPC/Kernel/
        mv ./utility/recovery.img ./utility/${VARIANT}-recovery.img
    fi

    if [ $ADD_MODULES -eq 1 ]; then
        for i in $(find ./ -name '*.ko'); do
            cp -av "$i" ./build-files/kernel-zip/system/lib/modules/ >/dev/null 2>&1
            rm -f "$i" >/dev/null 2>&1
            echo $i
        done;
    fi
done

cd $TMPDIR
tar -cvf bootimg.tar n91*-boot.img
xz -z -9 bootimg.tar
mv -f bootimg.tar.xz ../kernel-zip/bootimg.tar.xz
cd ../kernel-zip
rm $KERNEL_NAME > /dev/null 2>&1
rm ../../../HostPC/Kernel/out/$KERNEL_NAME > /dev/null 2>&1
7z a -mx9 $KERNEL_NAME *
zipalign -v 4 $KERNEL_NAME ../../../HostPC/Kernel/out/$KERNEL_NAME
rm bootimg.tar.xz > /dev/null 2>&1
rm $KERNEL_NAME > /dev/null 2>&1
cd $CDIR
rm $TMPDIR/* 2> /dev/null
echo ""
echo "------------------------   DONE!!   ----------------------------"
echo ""

