#!/system/bin/sh

BB="/res/bin/busybox";
SQLITE="/res/bin/sqlite3";
DB_SYNAPSE="/data/data/com.af.synapse/databases/actionValueStore";

CPUCLKMAX=`$SQLITE $DB_SYNAPSE "SELECT value FROM action_value WHERE key = 'generic /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq';"`;
CPUCLKMIN=`$SQLITE $DB_SYNAPSE "SELECT value FROM action_value WHERE key = 'generic /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq';"`;
echo $CPUCLKMAX > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq;
echo $CPUCLKMIN > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq;

