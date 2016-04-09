#!/sbin/sh

BB=/tmp/script/busybox

wbuildprop() {
    if [ ! `$BB grep $1 /system/build.prop` ]
    then
        echo "" >> /system/build.prop
        echo "$1=$2" >> /system/build.prop
    else
        $BB sed -i -e "s/$1=.*/$1=$2/g" /system/build.prop
    fi
}

#wbuildprop ro.config.tima 0
#wbuildprop ro.build.selinux 0
#wbuildprop ro.config.knox 0
#wbuildprop ro.securestorage.support false
#wbuildprop ro.securestorage.knox false
#wbuildprop wlan.wfd.hdcp disable

if [ ! `$BB grep "SYSTEMLESS" /data/.supersu` ]; then
    echo SYSTEMLESS=false>>/data/.supersu
else
    $BB sed -i -e "s/SYSTEMLESS=.*/SYSTEMLESS=false/g" /data/.supersu
fi

mkdir /system/etc/init.d

$BB chmod -R 0755 /data/StockRider/*
$BB chmod -R 0755 /system/etc/init.d
$BB chown -R root.root /system/etc/init.d
$BB chmod -R 0755 /system/etc/init.d-postboot
$BB chown -R root.root /system/etc/init.d-postboot

PKG_IGNORE=/data/media/0/Synapse/pakage_list_ignore.txt
PKG_SYSTEM=/data/media/0/Synapse/pakage_list_system.txt
PKG_GOOGLE=/data/media/0/Synapse/pakage_list_google.txt
PKG_AVAIL=/data/media/0/Synapse/pakage_list.txt
cp -f /tmp/script/pakage_list_ignore.txt $PKG_IGNORE
cp -f /tmp/script/pakage_list_system.txt $PKG_SYSTEM
cp -f /tmp/script/pakage_list_google.txt $PKG_GOOGLE
[ ! -f $PKG_AVAIL ] && cp -f /tmp/script/pakage_list.txt $PKG_AVAIL

