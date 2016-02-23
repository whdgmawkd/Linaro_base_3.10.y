#!/system/bin/sh

BB=/res/bin/busybox

$BB mount -t rootfs -o rw,remount rootfs
$BB mount -o rw,remount /system
$BB mount -o rw,remount /system /system

echo "" >> /data/StockRider/kernel.log
echo ---- start postboot script ---- >> /data/StockRider/kernel.log
echo "" >> /data/StockRider/kernel.log

echo init.d-postboot script is end >> /data/StockRider/kernel.log
echo - excecuted on $(date +"%Y-%d-%m %r") >> /data/StockRider/kernel.log

# Init.d
if [ ! -e /system/etc/init.d-postboot ]; then
  $BB mkdir /system/etc/init.d-postboot
  $BB chown -R root.root /system/etc/init.d-postboot
  $BB chmod -R 755 /system/etc/init.d-postboot
fi;

echo init.d-postboot script is start >> /data/StockRider/kernel.log
echo - excecuted on $(date +"%Y-%d-%m %r") >> /data/StockRider/kernel.log

for i in $(ls /system/etc/init.d-postboot); do
    echo init.d-postboot @ /system/etc/init.d-postboot/$i
    sh /system/etc/init.d-postboot/$i
done

/res/bin/busybox mount -t rootfs -o ro,remount rootfs
/res/bin/busybox mount -o remount,ro /system
/res/bin/busybox mount -o remount,ro /system /system

