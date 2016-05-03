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

/res/bin/busybox mount -t rootfs -o remount,rw rootfs
/res/bin/busybox mount -o remount,ro /system
/res/bin/busybox mount -o remount,ro /system /system

