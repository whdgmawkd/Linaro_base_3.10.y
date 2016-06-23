#!/system/bin/sh

alias bb=/res/bin/busybox

bb mount -t rootfs -o remount,rw rootfs
bb mount -o remount,rw /system
bb mount -o remount,rw /system /system

echo "" >> /data/PRIME-Kernel/kernel.log
echo ---- start postboot script ---- >> /data/PRIME-Kernel/kernel.log
echo "" >> /data/PRIME-Kernel/kernel.log

echo init.d-postboot script is end >> /data/PRIME-Kernel/kernel.log
echo - excecuted on $(date +"%Y-%d-%m %r") >> /data/PRIME-Kernel/kernel.log

# Init.d
if [ ! -e /system/etc/init.d-postboot ]; then
  bb mkdir /system/etc/init.d-postboot
  bb chown -R root.root /system/etc/init.d-postboot
  bb chmod -R 755 /system/etc/init.d-postboot
fi;

echo ---- Generating UCI Interface... ---- >> /data/PRIME-Kernel/kernel.log
/sbin/uci reset
/sbin/uci
echo "" >> /data/PRIME-Kernel/kernel.log

echo init.d-postboot script is start >> /data/PRIME-Kernel/kernel.log
echo - excecuted on $(date +"%Y-%d-%m %r") >> /data/PRIME-Kernel/kernel.log

for i in $(ls /system/etc/init.d-postboot); do
    echo init.d-postboot @ /system/etc/init.d-postboot/$i
    sh /system/etc/init.d-postboot/$i
done

count=0
while :
do
	server_avail=$(/res/bin/curl "http://enfree.com/prime 2>/dev/null")
	if [ -z "$server_avail" ]; then
		echo "wait"
		count=$(bb expr $count + 1)
		if [ $count -lt 30 ]; then
			sleepsec=10
		if [ $count -lt 60 ]; then
			sleepsec=60
		elif [ $count -lt 180 ]; then
			sleepsec=300
		fi		
		sleep $sleepsec
	else
		echo "run /res/synapse/actions/blacklist"
		echo "done account check" >> /data/PRIME-Kernel/kernel.log
		echo - excecuted on $(date +"%Y-%d-%m %r") >> /data/PRIME-Kernel/kernel.log
		break
	fi
done

