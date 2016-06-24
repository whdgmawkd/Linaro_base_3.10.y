#!/system/bin/sh

alias bb=/res/bin/busybox
PRIME=/data/PRIME-Kernel
LIST_BRIDGE=$(cat $PRIME/list/list_xposed_bridge.txt)
HIDE_BRIDGE=$(cat $PRIME/synapse/settings/root_hide_bridge)
HIDE_XPOSED=$(cat $PRIME/synapse/settings/root_hide_xposed)
HIDE_SU_APK=$(cat $PRIME/synapse/settings/root_hide_supersu)
HIDE_SU_BIN=$(cat $PRIME/synapse/settings/root_hide_subin)
LIST_SU_BIN=$(cat $PRIME/list/list_supersu_bins.txt)
BAKDIR=$PRIME/xposed-backup
XPOSED_BACKUPS=`ls $BAKDIR|grep ".apk"`
PM_SVC=0
PM_FLAG=0
SUBIN_ENABLE=0

if [ $HIDE_XPOSED -eq 1 ]; then
	APKS1=$(cat $PRIME/list/list_xposed_apks.txt)
fi
if [ $HIDE_SU -eq 1 ]; then
	APKS2=$(cat $PRIME/list/list_supersu_apks.txt)
fi
XPOSED_APK="$APKS1 $APKS2"

(
if [ ! -z "$XPOSED_BACKUPS" ]; then

	if [ $SUBIN_ENABLE -eq 1 ]; then
		for BINS in $LIST_SU_BIN
		do
			[ -z "$BINS" ] && continue
			BASENAME=$(basename $BINS)
			DIRNAME=$(dirname $BINS)
			FULLPATH_BIN="$DIRNAME/primebackup_$BASENAME"
			if [ -f $FULLPATH_BIN ]; then
				bb mv $FULLPATH_BIN $BINS
			fi
		done
	fi

	while :
	do
		PM_SVC=`service list | bb grep -c 'package:'`
		[ $PM_SVC -eq 1 ] && break
		sleep 1
	done

	for apps in $XPOSED_APK
	do
		[ -z "$apps" ] && continue
		DATA=/data/data/$apps
		if [ -f $BAKDIR/$apps.apk ] && [ ! -e $DATA ]; then
			echo "Restore Xposed Framework" >> /data/PRIME-Kernel/kernel.log
			echo - excecuted on $(date +"%Y-%d-%m %r") >> /data/PRIME-Kernel/kernel.log
			bb rm -f /data/app/$apps-*
			bb chmod 0774 $PRIME/xposed-backup/$apps.apk
			pm install $PRIME/xposed-backup/$apps.apk 2>> /data/PRIME-Kernel/kernel.log
			ERR=$?

			[ $ERR -ne 0 ] && continue

			if [ -e $DATA ]; then
				OWN=`bb stat -c %u.%g $DATA`
				bb tar -xzf $BAKDIR/$apps.data.tar.gz -C $DATA
				chown -R $OWN $DATA
			fi
			
			PM_FLAG=1
		fi
	done

	for bridge in $LIST_BRIDGE
	do
		[ -z "$bridge" ] && continue
		if [ -f $PRIME/xposed-backup/$bridge.bak ]; then
			bb mv $PRIME/xposed-backup/$bridge.bak /system/framework/$bridge
			bb chmod 0644 /system/framework/$bridge
			break
		fi
	done
	if [ $PM_FLAG -eq 1 ]; then
		sync
		sleep 1
		reboot
	fi
fi
) &
