#!/system/bin/sh

alias bb=/res/bin/busybox
PRIME=/data/PRIME-Kernel
LIST_BRIDGE=$(cat $PRIME/list/list_xposed_bridge.txt)
HIDE_BRIDGE=$(cat $PRIME/synapse/settings/root_hide_bridge)
HIDE_SU=$(cat $PRIME/synapse/settings/root_hide_supersu)
BAKDIR=$PRIME/xposed-backup
XPOSED_BACKUPS=`ls $BAKDIR|grep ".apk"`
PM_SVC=0
PM_FLAG=0

if [ $HIDE_SU -eq 1 ]; then
	XPOSED_APK=$(cat $PRIME/list/list_xposed_apks.txt $PRIME/list/list_supersu_apks.txt)
else
	XPOSED_APK=$(cat $PRIME/list/list_xposed_apks.txt)
fi

if [ ! -z "$XPOSED_BACKUPS" ]; then
	while [ $PM_SVC -eq 0 ]
	do
		PM_SVC=`service list|bb grep -c 'package:'`
		sleep 1
	done

	for apps in $XPOSED_APK
	do
		[ -z "$apps" ] && continue
		DATA=/data/data/$apps
		if [ -f $BAKDIR/$apps.apk ] && [ ! -e $DATA ]; then
			echo "Restore Xposed Framework" >> /data/PRIME-Kernel/kernel.log
			echo - excecuted on $(date +"%Y-%d-%m %r") >> /data/PRIME-Kernel/kernel.log
			rm -f /data/app/$apps-*
			chmod 0774 $PRIME/xposed-backup/$apps.apk
			pm install $PRIME/xposed-backup/$apps.apk 2>> /data/PRIME-Kernel/kernel.log
			ERR=$?
			[ $ERR -eq 0 ] && PM_FLAG=1
		fi
	done
	for bridge in $LIST_BRIDGE
	do
		[ -z "$bridge" ] && continue
		if [ -f /system/framework/$bridge.bak ]; then
			mv /system/framework/$bridge.bak /system/framework/$bridge
		fi
	done
	if [ $PM_FLAG -eq 1 ]; then
		for apps in $XPOSED_APK
		do
			[ -z "$apps" ] && continue
			DATA=/data/data/$apps
			if [ -e $DATA ]; then
				OWN=`bb stat -c %u.%g $DATA`
				bb tar -xzf $BAKDIR/$apps.data.tar.gz -C $DATA
				bb chown -R $OWN $DATA
			fi
		done
		sync
		sleep 1
		reboot
	fi
fi
