#!/sbin/sh

alias bb=/tmp/script/busybox

#bb rm -rf /cache/*
if [ ! -e /data/media/0/Synapse/.do_not_remove_data ]; then
    bb rm -rf /data/data/com.af.synapse
    bb rm -rf /data/data/com.af.synapse-*
fi
bb rm -f /data/su.img
bb rm /system/xbin/uci
bb rm /system/etc/init.d/voltage
bb rm /system/etc/init.d/fix_overays
bb rm /system/etc/init.d/01stockrider_kernel
bb rm /system/etc/init.d-postboot/killapps
bb rm /system/etc/init.d-postboot/patch-GMS_Drain

if [ -e /system/xbin/busybox ]; then
    for i in $(bb --list); do
        bb rm /system/xbin/$i
    done
    rm /system/xbin/busybox
fi;
