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
bb mount -o remount,rw /system
bb mount -o remount,rw /system /system

# bb --install -s /res/bin/
bb chmod -R 0755 /res/bin

# Support LGU-IWLAN
device=`getprop ro.bootloader`
carrier=${device:4:1}
if [ $carrier == "L" ]; then
	setprop sys.lgt.mobicoredaemon.enable true
fi

echo interactive > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo interactive > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor

# Configure interactive - cpu0
echo 19000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/boost
echo 40000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/boostpulse_duration
echo 85 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
echo 900000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
echo 40000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
echo 75 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
echo 20000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
echo 20000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_slack
echo 100000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis

# Configure interactive - cpu4
echo 59000 1200000:119000 1700000:19000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/boost
echo 40000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/boostpulse_duration
echo 85 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
echo 1000000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
echo 99000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
echo 60 1300000:63 1500000:65 190000:70 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
echo 20000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
echo 20000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_slack
echo 90000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis

# Configure cafactive
echo cafactive > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo cafactive > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor

# Configure cafactive - cpu0
echo 19000 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/above_hispeed_delay
echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/boost
echo 40000 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/boostpulse_duration
echo 85 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/go_hispeed_load
echo 900000 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/hispeed_freq
echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/io_is_busy
echo 40000 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/min_sample_time
echo 75 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/target_loads
echo 20000 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/timer_rate
echo 20000 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/timer_slack
echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/max_freq_hysteresis
# Configure cafactive - cpu4
echo 19000 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/above_hispeed_delay
echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/boost
echo 40000 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/boostpulse_duration
echo 85 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/go_hispeed_load
echo 1600000 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/hispeed_freq
echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/io_is_busy
echo 99000 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/min_sample_time
echo 60 1300000:63 1500000:65 190000:70 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/target_loads
echo 20000 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/timer_rate
echo 20000 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/timer_slack
echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/max_freq_hysteresis

# io_is_busy
echo 1 > /sys/devices/virtual/sec/sec_slow/io_is_busy

# default governor by interactive
echo interactive > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo interactive > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor

# fix some kernel value
for i in /sys/block/*/queue/add_random; do echo 0 > $i; done
for i in /sys/block/*/queue/rq_affinity; do echo 2 > $i; done
if [ -e /sys/block/zram0 ]; then
    local ZRM=`ls -d /sys/block/zram*`;
    for i in $ZRM; do
		echo "0" > $i/queue/rotational;
		echo "0" > $i/queue/iostats;
		echo "1" > $i/queue/rq_affinity;
		echo lz4 > $i/comp_algorithm
    done;
fi;
echo Default > /sys/devices/14ac0000.mali/dvfs_governor
echo Y > /sys/module/mmc_core/parameters/use_spi_crc
echo 0 > /sys/kernel/dyn_fsync/Dyn_fsync_active
echo 0 > /proc/sys/vm/dynamic_dirty_writeback
echo 0 > /proc/sys/kernel/randomize_va_space
echo 0 > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk
echo 1 > /sys/kernel/logger_mode/logger_mode
echo 400000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1300000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 700000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
echo 1900000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
echo 30 > /sys/module/zswap/parameters/max_pool_percent
echo 40960 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
echo 0 > /sys/module/mdnie_lite/parameters/enable_toggle_negative

cpuvoltTable=/sys/devices/system/cpu/cpufreq/mp-cpufreq/cpu_volt_table
bb chmod 666 $cpuvoltTable
gpuvoltTable=/sys/devices/14ac0000.mali/volt_table
bb chmod 666 $gpuvoltTable
setVoltage() {
    getVal=`grep "^$1 " $3`;
    if [ "$getVal" ]; then
        echo $1 : $2
        echo $1 $2 > $3
    fi
}

SET_CUSTOM_CPUFREQ=0
if [ $SET_CUSTOM_CPUFREQ == 1 ]; then
	setVoltage 900000 900000 $cpuvoltTable
	setVoltage 800000 875000 $cpuvoltTable
	setVoltage 700000 850000 $cpuvoltTable
	setVoltage 600000 825000 $cpuvoltTable
	setVoltage 500000 800000 $cpuvoltTable
	setVoltage 400000 775000 $cpuvoltTable
	setVoltage 300000 775000 $cpuvoltTable
	setVoltage 200000 775000 $cpuvoltTable
fi

setVoltage 800 1187500 $gpuvoltTable
setVoltage 772 1175000 $gpuvoltTable
setVoltage 730 1131250 $gpuvoltTable
setVoltage 700 1068750 $gpuvoltTable
setVoltage 667 1025000 $gpuvoltTable
setVoltage 650 1025000 $gpuvoltTable
setVoltage 100 775000 $gpuvoltTable

echo "1 1200000 1200000 0 0 1" > /sys/class/input_booster/key/freq
echo "1 0 500 0" > /sys/class/input_booster/key/time

#echo "1 1200000 1200000 0 0 1" > /sys/class/input_booster/touchkey/freq
#echo "1 0 500 0" > /sys/class/input_booster/touchkey/time

echo "2 0 1200000 0 0 0" > /sys/class/input_booster/touch/freq
echo "3 0 800000 0 0 0" > /sys/class/input_booster/touch/freq

echo "1 0 0 0" > /sys/class/input_booster/touch/time
echo "2 130 500 0" > /sys/class/input_booster/touch/time
echo "3 0 500 0" > /sys/class/input_booster/touch/time

if [ ! -f /system/.knox_removed ]; then
    bb rm -rf /system/app/Bridge
    bb rm -rf /system/app/KnoxAttestationAgent
    bb rm -rf /system/app/KnoxFolderContainer
    bb rm -rf /system/app/KnoxSetupWizardClient
    bb rm -rf /system/app/SwitchKnoxI
    bb rm -rf /system/app/SwitchKnoxII
    bb rm -rf /system/app/SPDClient
    bb rm -rf /system/app/AASAservice
    bb rm -rf /system/app/BBCAgent
    bb rm -rf /system/priv-app/SPDClient
    bb rm -rf /system/priv-app/KLMSAgent
#    bb rm -rf /system/tima_measurement_info
    bb rm -rf /system/container
#    bb rm -rf /system/preloadedkiosk
#    bb rm -rf /system/preloadedsso
#    bb rm -rf /system/etc/secure_storage/com.sec.knox.store
#    bb rm -rf /data/data/com.samsung.klmsagent
#    bb rm -rf /data/data/com.samsung.knox.rcp.components
#    bb rm -rf /data/data/com.sec.enterprise.knox.attestation
#    bb rm -rf /data/data/com.sec.enterprise.knox.cloudmdm.smdms
#    bb rm -rf /data/data/com.sec.knox.bridge
#    bb rm -rf /data/data/com.sec.knox.containeragent2
#    bb rm -rf /data/data/com.sec.knox.knoxsetupwizardclient
#    bb rm -rf /data/data/com.sec.knox.packageverifier
#    bb rm -rf /data/data/com.sec.knox.shortcutsms
#    bb rm -rf /data/data/com.sec.knox.switcher
#    bb rm -rf /data/data/com.sec.knox.SwitchKnoxI
#    bb rm -rf /data/data/com.sec.knox.SwitchKnoxII
#    bb rm -rf /data/knox
#    bb rm -rf /mnt/shell/knox-emulated
#    bb rm -rf /knox_data
#    bb rm -rf /storage/knox-emulated
#    bb rm -rf /system/priv-app/SecurityLogAgent
#    bb rm -rf /system/priv-app/SecurityManagerService
#    bb rm -rf /system/priv-app/SecurityProviderSEC
    
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

