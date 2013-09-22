#!/bin/bash

SLMODEMD_BIN=/usr/sbin/slmodemd
SLMODEMD_DEVICE=/dev/slusb0
SLMODEMD_COUNTRY=ROMANIA
ROOT_UID=0 # Only users with $UID 0 have root privileges
E_NOTROOT=67 # Non-root exit error
E_GENERAL=1

# Run as root
if [ "$UID" -ne "$ROOT_UID" ]; then
    echo "Must be root to run this script."
    exit $E_NOTROOT
fi

# Check for missing daemon 
if [ ! -x $SLMODEMD_BIN ]; then
    echo "slmodemd: $SLMODEMD_BIN not found"
    exit 5
fi

# Check for kernel modules
MODULE_NAME=`echo $SLMODEMD_DEVICE | cut -c6-10`
case $MODULE_NAME in
    slamr)
        grep -q 'slamr\..*o' /lib/modules/`uname -r`/modules.dep || \
	    { echo "slmodemd: kernel module slamr.(k)o missing"; exit $E_GENERAL; }
        ;;
    slusb)
    	grep -q 'slusb\..*o' /lib/modules/`uname -r`/modules.dep || \
	    { echo "slmodemd: kernel module slusb.(k)o missing"; exit $E_GENERAL; }
        ;;
    *)
        echo "slmodemd: no kernel module for $SLMODEMD_DEVICE - broken config?"
	exit $E_GENERAL
	;;
esac

# Source SUSE rc functions and reset
. /etc/rc.status
rc_reset

case "$1" in
    start)
	echo -n "Starting slmodemd"
	# loading modules also required for restart
	modprobe $MODULE_NAME
	mknod -m 600 $SLMODEMD_DEVICE  c   243   0
	startproc $SLMODEMD_BIN --country=$SLMODEMD_COUNTRY $SLMODEMD_DEVICE > /dev/null 2>&1
	rc_status -v
	;;
    stop)
	echo -n "Shutting down slmodemd"
	killproc -TERM $SLMODEMD_BIN
	rm -f $SLMODEMD_DEVICE
	modprobe -r $MODULE_NAME
	rc_status -v
	;;
    reload|restart)
	$0 stop
	$0 start
	rc_status
	;;
    try-restart)
        # only restart if already running
        if [ "`$0 status > /dev/null 2>&1`" == "0" ]; then
	    $0 restart
	else
	    echo "slmodemd not running"
	fi
	rc_status
	;;
    status)
        echo -n "slmodemd is:"
        checkproc $SLMODEMD_BIN
	rc_status -v
	;;	
    *)
	echo "Usage: $0 {start|stop|reload|restart|try-restart|status}"
	exit $E_GENERAL
	;;
esac
rc_exit


