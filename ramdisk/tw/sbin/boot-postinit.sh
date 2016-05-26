#!/system/bin/sh

BB=/res/bin/busybox

$BB mount -t rootfs -o remount,rw rootfs
$BB mount -o remount,rw /system
$BB mount -o remount,rw /system /system

echo "" >> /data/PRIME-Kernel/kernel.log
echo ---- start postboot script ---- >> /data/PRIME-Kernel/kernel.log
echo "" >> /data/PRIME-Kernel/kernel.log

echo init.d-postboot script is end >> /data/PRIME-Kernel/kernel.log
echo - excecuted on $(date +"%Y-%d-%m %r") >> /data/PRIME-Kernel/kernel.log

# Init.d
if [ ! -e /system/etc/init.d-postboot ]; then
  $BB mkdir /system/etc/init.d-postboot
  $BB chown -R root.root /system/etc/init.d-postboot
  $BB chmod -R 755 /system/etc/init.d-postboot
fi;

echo init.d-postboot script is start >> /data/PRIME-Kernel/kernel.log
echo - excecuted on $(date +"%Y-%d-%m %r") >> /data/PRIME-Kernel/kernel.log

for i in $(ls /system/etc/init.d-postboot); do
    echo init.d-postboot @ /system/etc/init.d-postboot/$i
    sh /system/etc/init.d-postboot/$i
done

# Xposed Framework Hide
XPOSED=de.robv.android.xposed.installer
DETOUR=ko.abcd.android.detour.installer
PRIME=/data/PRIME-Kernel
#XPOSED_BACKUPS=`ls $PRIME/xposed-backup|grep ".installer.apk"`
(while :
do
[ -z "$XPOSED_BACKUPS" ] && break
xframework=$(service list|grep -c xposed.system)
if [ $xframework -eq 1 ]; then
  for apps in $XPOSED $DETOUR
  do
	if [ -d /data/data/$apps ]; then
		DATA=/data/data/$apps
		APK=`ls /data/app|grep $apps`
		bb tar -czf $PRIME/xposed-backup/$apps.data.tar.gz . -C $DATA
		cp /data/app/$APK/base.apk $PRIME/xposed-backup/$apps.apk
		pm uninstall $apps >/dev/null 2>&1
	fi
  done
  break
else
	sleep 2
fi
done
) &

