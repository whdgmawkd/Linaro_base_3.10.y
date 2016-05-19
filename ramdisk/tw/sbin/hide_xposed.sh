#!/system/bin/sh

alias bb=/res/bin/busybox
PRIME=/data/PRIME-Kernel
XPOSED=de.robv.android.xposed.installer
DETOUR=ko.abcd.android.detour.installer
XPOSED_BACKUPS=`ls $PRIME/xposed-backup|grep ".installer.apk"`

(while :
do
  [ -z "$XPOSED_BACKUPS" ] && break
  package_svc=`service list|grep -c package`
  if [ $package_svc -eq 1 ]; then

	for apps in $XPOSED $DETOUR
	do
		echo "Un-Hide: $apps"
		DATA=/data/data/$apps
		if [ ! -e $DATA ]; then
			echo "Restore Xposed Framework" >> /data/PRIME-Kernel/kernel.log
			echo - excecuted on $(date +"%Y-%d-%m %r") >> /data/PRIME-Kernel/kernel.log
			chmod 0775 $PRIME/xposed-backup
			chmod 0774 $PRIME/xposed-backup/$apps.apk
			pm install $PRIME/xposed-backup/$apps.apk 2>> /data/PRIME-Kernel/kernel.log
			#rm -f /data/app/$apps-*
			#mkdir /data/app/$apps-1
			#chmod 0755 /data/app/$apps-1
			#cp $PRIME/xposed-backup/$apps.apk /data/app/$apps-1/base.apk
			#chmod 0644 /data/app/$apps-1/base.apk
		fi
	done

	for apps in $XPOSED $DETOUR
    do
		DATA=/data/data/$apps
		OWN=`bb stat -c %u.%g $DATA`
		bb tar -xzf $PRIME/xposed-backup/$apps.data.tar.gz -C $DATA
		bb chown -R $OWN $DATA
    done
    break
  else
  	sleep 1
  fi
done
) &
