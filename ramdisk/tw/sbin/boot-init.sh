#!/res/bin/busybox sh

BB=/res/bin/busybox

[ ! -e /data/PRIME-Kernel ] && $BB mkdir -p /data/PRIME-Kernel
echo "" > /data/PRIME-Kernel/kernel.log

echo "FSTrim Excute" >> /data/PRIME-Kernel/kernel.log
echo - excecuted on $(date +"%Y-%d-%m %r") >> /data/PRIME-Kernel/kernel.log
$BB fstrim /system
$BB fstrim /data
$BB fstrim /cache
$BB mount -t rootfs -o remount,rw rootfs
$BB mount -o rw,remount /system
$BB mount -o rw,remount /system /system

# $BB --install -s /res/bin/
$BB chmod -R 0755 /res/bin

# Support LGU-IWLAN
device=`getprop ro.bootloader`
carrier=${device:4:1}
if [ $carrier == "L" ]; then
	setprop sys.lgt.mobicoredaemon.enable true
fi

# Configure interactive
echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
echo 200000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis
echo 50000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis
echo 900000 > /sys/devices/system/cpu/cpu0/interactive/hispeed_freq
echo 1200000 > /sys/devices/system/cpu/cpu4/interactive/hispeed_freq
echo 140 > /sys/devices/system/cpu/cpu0/interactive/go_hispeed_load

# Configure cafactive
echo cafactive > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo cafactive > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
echo 20000 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/timer_rate
echo 80000 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/timer_slack
echo 80000 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/min_sample_time
echo 900000 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/hispeed_freq
echo 140 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/go_hispeed_load
echo 75 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/target_loads
echo 19000 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/above_hispeed_delay
echo 80000 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/boostpulse_duration
echo 100000 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/max_freq_hysteresis
echo 20000 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/timer_rate
echo 20000 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/timer_slack
echo 80000 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/min_sample_time
echo 1200000 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/hispeed_freq
echo 89 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/go_hispeed_load
echo "60 1300000:63 1500000:65 1900000:70" > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/target_loads
echo "20000 1300000:39000 1700000:19000" > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/above_hispeed_delay
echo 40000 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/boostpulse_duration
echo 200000 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/max_freq_hysteresis
echo 50000 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/max_freq_hysteresis

# io_is_busy
echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/cafactive/io_is_busy
echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/cafactive/io_is_busy
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
echo 0 > /sys/devices/14ac0000.mali/dvfs_governor
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
echo 70 > /sys/module/zswap/parameters/max_pool_percent
echo 40960 > /sys/module/lowmemorykiller/parameters/vmpressure_file_min
echo 0 > /sys/module/mdnie_lite/parameters/enable_toggle_negative

cpuvoltTable=/sys/devices/system/cpu/cpufreq/mp-cpufreq/cpu_volt_table
$BB chmod 666 $cpuvoltTable
gpuvoltTable=/sys/devices/14ac0000.mali/volt_table
$BB chmod 666 $gpuvoltTable
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

# Allow untrusted apps to read from debugfs
if [ -e /system/lib/libsupol.so ]; then
/system/xbin/supolicy --live \
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

if [ ! -f /system/.knox_removed ]; then
    $BB rm -rf /system/app/Bridge
    $BB rm -rf /system/app/KnoxAttestationAgent
    $BB rm -rf /system/app/KnoxFolderContainer
    $BB rm -rf /system/app/KnoxSetupWizardClient
    $BB rm -rf /system/app/SwitchKnoxI
    $BB rm -rf /system/app/SwitchKnoxII
    $BB rm -rf /system/app/SPDClient
    $BB rm -rf /system/app/AASAservice
    $BB rm -rf /system/app/BBCAgent
    $BB rm -rf /system/priv-app/SPDClient
    $BB rm -rf /system/priv-app/KLMSAgent
#    $BB rm -rf /system/tima_measurement_info
    $BB rm -rf /system/container
#    $BB rm -rf /system/preloadedkiosk
#    $BB rm -rf /system/preloadedsso
#    $BB rm -rf /system/etc/secure_storage/com.sec.knox.store
#    $BB rm -rf /data/data/com.samsung.klmsagent
#    $BB rm -rf /data/data/com.samsung.knox.rcp.components
#    $BB rm -rf /data/data/com.sec.enterprise.knox.attestation
#    $BB rm -rf /data/data/com.sec.enterprise.knox.cloudmdm.smdms
#    $BB rm -rf /data/data/com.sec.knox.bridge
#    $BB rm -rf /data/data/com.sec.knox.containeragent2
#    $BB rm -rf /data/data/com.sec.knox.knoxsetupwizardclient
#    $BB rm -rf /data/data/com.sec.knox.packageverifier
#    $BB rm -rf /data/data/com.sec.knox.shortcutsms
#    $BB rm -rf /data/data/com.sec.knox.switcher
#    $BB rm -rf /data/data/com.sec.knox.SwitchKnoxI
#    $BB rm -rf /data/data/com.sec.knox.SwitchKnoxII
#    $BB rm -rf /data/knox
#    $BB rm -rf /mnt/shell/knox-emulated
#    $BB rm -rf /knox_data
#    $BB rm -rf /storage/knox-emulated
#    pm disable com.sec.knox.seandroid
#    pm disable com.samsung.android.securitylogagent
#    $BB rm -rf /system/priv-app/SecurityLogAgent
#    $BB rm -rf /system/priv-app/SecurityManagerService
#    $BB rm -rf /system/priv-app/SecurityProviderSEC
    
    touch /system/.knox_removed
fi

$BB mount -t rootfs -o remount,rw rootfs
$BB chmod -R 0755 /res/bin
$BB chmod -R 0755 /res/synapse
$BB chmod 0755 /sbin/uci

# busybox install
INS_XBIN=`cat /data/PRIME-Kernel/synapse/settings/bbins_xbin`
INS_LAST=`cat /data/PRIME-Kernel/synapse/settings/bbins_last`
if [ $INS_LAST -eq 1 ]; then
	if [ $INS_XBIN -eq 0 ]; then P=/res/bin/bb;
	else P=/system/xbin; fi
	if [ ! -f $P/busybox ]; then
		$BB ln -sf /res/bin/busybox $P/busybox
		$P/busybox --install -s $P
	fi
fi

/sbin/uci reset
/sbin/uci

source /sbin/synapse_loader.sh

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

$BB mount -t rootfs -o remount,ro rootfs
$BB mount -o remount,ro /system
$BB mount -o remount,ro /system /system

