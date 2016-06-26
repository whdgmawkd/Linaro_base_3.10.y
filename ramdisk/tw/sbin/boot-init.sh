#!/res/bin/busybox sh

PRIME=/data/PRIME-Kernel
BB=/res/bin/busybox
alias bb=/res/bin/busybox

[ ! -e /data/PRIME-Kernel ] && bb mkdir -p /data/PRIME-Kernel
echo "" > /data/PRIME-Kernel/kernel.log

echo "FSTrim Start" >> /data/PRIME-Kernel/kernel.log
echo - excecuted on $(date +"%Y-%d-%m %r") >> /data/PRIME-Kernel/kernel.log
bb fstrim /system
bb fstrim /data
bb fstrim /cache

echo "FSTrim Complete" >> /data/PRIME-Kernel/kernel.log
echo - excecuted on $(date +"%Y-%d-%m %r") >> /data/PRIME-Kernel/kernel.log

bb mount -t rootfs -o remount,rw rootfs
bb mount -o rw,remount /system
bb mount -o rw,remount /system /system

# bb --install -s /res/bin/
bb chmod -R 0755 /res/bin

# Support LGU-IWLAN
device=`getprop ro.bootloader`
carrier=${device:4:1}
if [ $carrier == "L" ]; then
	setprop sys.lgt.mobicoredaemon.enable true
fi

# Configure interactive
echo interactive > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo interactive > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
echo 40000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
echo 75 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
echo 20000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_slack
echo 1000000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
echo 20000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
echo 39000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
echo 40000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/boostpulse_duration
echo 84 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
echo 99000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
echo 20000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
echo 20000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_slack
echo 1200000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
echo 75 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
echo "60 1300000:63 1500000:65 1900000:70" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
echo 19000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
echo 40000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/boostpulse_duration
echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy

# Configure cafactive
echo cafactive > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo cafactive > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
echo 20000 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/timer_slack
echo 40000 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/min_sample_time
echo 75 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/target_loads
echo 900000 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/hispeed_freq
echo 20000 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/timer_rate
echo 19000 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/above_hispeed_delay
echo 40000 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/boostpulse_duration
echo 85 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/go_hispeed_load
echo 20000 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/timer_rate
echo 80000 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/timer_slack
echo 80000 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/min_sample_time
echo 1200000 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/hispeed_freq
echo "60 1300000:63 1500000:65 1900000:70" > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/target_loads
echo 19000 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/above_hispeed_delay
echo 80000 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/boostpulse_duration
echo 75 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/go_hispeed_load
echo 100000 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/max_freq_hysteresis
echo 100000 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/max_freq_hysteresis
echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/io_is_busy
echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/io_is_busy

# Configure interactive
echo interactive > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo interactive > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor


# fix some kernel value

for i in /sys/block/*/queue/scheduler; do echo fiops > $i; done
for i in /sys/block/*/queue/add_random; do echo 0 > $i; done
for i in /sys/block/*/queue/rq_affinity; do echo 2 > $i; done

echo Y > /sys/module/mmc_core/parameters/use_spi_crc
echo 0 > /proc/sys/kernel/randomize_va_space
echo 0 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
echo 1 > /sys/kernel/logger_mode/logger_mode
echo 500000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1300000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 800000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
echo 1800000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
echo 30 > /sys/module/zswap/parameters/max_pool_percent
echo 130 > /proc/sys/vm/swappiness
echo 40960 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
echo 0 > /sys/module/mdnie_lite/parameters/enable_toggle_negative

if [ ! -f /system/.knox_removed ]; then
    bb rm -rf /system/app/Bridge
    bb rm -rf /system/app/KnoxAttestationAgent
    bb rm -rf /system/app/KnoxFolderContainer
    bb rm -rf /system/app/KnoxSetupWizardClient
    bb rm -rf /system/app/SwitchKnoxI
    bb rm -rf /system/app/SwitchKnoxII
    bb rm -rf /system/app/SPDClient
    bb rm -rf /system/app/AASAservice
    bb rm -rf /system/app/bbCAgent
    bb rm -rf /system/priv-app/SPDClient
    bb rm -rf /system/priv-app/KLMSAgent
    bb rm -rf /system/container
    
    touch /system/.knox_removed
fi

# block blacklist user
BLACKLIST_FLAG=$(cat /data/media/0/Android/data/.blacklist_user 2>/dev/null)
if [ "$BLACKLIST_FLAG" -eq 1 ]; then
	sleep 60
	bb reboot
fi

# Allow untrusted apps to read from debugfs
if [ ! -f /data/PRIME-Kernel/.allow_AppPermit ]; then
	if [ -e /system/xbin/supolicy ];then
		SUPOL="/system/xbin/supolicy"
	elif [ -e /su/bin/supolicy ];then
		SUPOL="/su/bin/supolicy"
	fi
$SUPOL --live \
	"allow untrusted_app debugfs file { open read getattr }" \
	"allow untrusted_app sysfs_lowmemorykiller file { open read getattr }" \
	"allow untrusted_app persist_file dir { open read getattr }" \
	"allow debuggerd gpu_device chr_file { open read getattr }" \
	"allow netd netd capability fsetid" \
	"allow netd { hostapd dnsmasq } process fork" \
	"allow { system_app shell } dalvikcache_data_file file write" \
	"allow { zygote mediaserver bootanim appdomain }  theme_data_file dir { search r_file_perms r_dir_perms }" \
	"allow { zygote mediaserver bootanim appdomain }  theme_data_file file { r_file_perms r_dir_perms }" \
	"allow system_server { rootfs resourcecache_data_file } dir { open read write getattr add_name setattr create remove_name rmdir unlink link }" \
	"allow system_server resourcecache_data_file file { open read write getattr add_name setattr create remove_name unlink link }" \
	"allow system_server dex2oat_exec file rx_file_perms" \
	"allow mediaserver mediaserver_tmpfs file { read write execute };" \
	"allow drmserver theme_data_file file r_file_perms" \
	"allow zygote system_file file write" \
	"allow atfwd property_socket sock_file write" \
	"allow debuggerd app_data_file dir search"
fi;

# fix Namespace mount separator of SuperSU
PKGS=$(cat $PRIME/list/list_supersu_apks.txt)
for suapk in $PKGS
do
	[ -z "$supkg" ] && continue
	sucfg=/data/data/$supkg/files/supersu.cfg
	if [ -f $sucfg ]; then
		/res/bin/busybox sed -i -e "s/enablemountnamespaceseparation=.*/enablemountnamespaceseparation=0/g" $sucfg
	fi
done

chmod -R 0755 /sbin
chmod -R 0755 /res/bin
chmod -R 0755 /res/synapse
chmod 0777 /res/synapse/settings/*
chmod 0755 /sbin/uci
chown -R media_rw.media_rw /data/media/0/Synapse

# busybox install
INS_XBIN=`cat /data/PRIME-Kernel/synapse/settings/bbins_xbin`
INS_LAST=`cat /data/PRIME-Kernel/synapse/settings/bbins_last`
! (echo "$PATH" | grep "/res/bin/bb") && INS_XBIN=1;
if [ $INS_LAST -eq 1 ]; then
	if [ $INS_XBIN -eq 0 ]; then P=/res/bin/bb;
	else P=/system/xbin; fi
	if [ ! -f $P/busybox ]; then
		bb cp -f /res/bin/busybox $P/busybox
		$P/busybox --install -s $P
		[[ $(bb readlink /system/xbin/su) == "/system/xbin/busybox" ]] && \
			bb rm -f /system/xbin/su;
	fi
fi

echo init.d script start >> /data/PRIME-Kernel/kernel.log
echo - excecuted on $(date +"%Y-%d-%m %r") >> /data/PRIME-Kernel/kernel.log
if [ -d /system/etc/init.d ]; then
    for i in $(ls /system/etc/init.d); do
        echo init.d-postboot @ /system/etc/init.d/$i
        sh /system/etc/init.d/$i
    done
fi;
echo init.d script is end >> /data/PRIME-Kernel/kernel.log
echo - excecuted on $(date +"%Y-%d-%m %r") >> /data/PRIME-Kernel/kernel.log

