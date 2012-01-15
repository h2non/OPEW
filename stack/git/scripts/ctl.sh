#!/bin/sh
#
#   Startup/shutdown script for Git Daemon
#
#   Linux chkconfig stuff:
#
#   chkconfig: 345 56 10
#   description: Startup/shutdown script for Git Daemon
#
# . /etc/init.d/functions

DAEMON=/opt/opew/stack/git/libexec/git-core/git-daemon
PID=/opt/opew/stack/git/git-daemon.pid
ARGS="--base-path=/opt/opew/stack/git/ --detach --user=opew --group=opew --port=9418 --listen=0.0.0.0 --pid-file=$PID"

prog=git-daemon

start () {
	if [ ! -f $PID ]; then

	echo -n "Starting $prog: "

    	# start daemon
    	$DAEMON $ARGS >> /opt/opew/stack/git/git-daemon.log
        RETVAL=$?
    	[ $RETVAL = 0 ] 
	sleep 1
    	echo -n "done!\n"
    	else 
		echo "Git is already running!"
	fi
	return $RETVAL
}

stop () {
    # stop daemon
    if [ -f $PID ]; then
    	kill `cat $PID`
	echo -n "Stopping $prog: "
	RETVAL=$?

    	if [ $RETVAL = 0 ]; then
		rm -f $PID
		sleep 1
		echo -n "done!\n"
   	fi
    else 
	echo -n "Git is not running!\n" 
    fi
}

restart() {
    stop
    sleep 1
    start
}

case $1 in
    start)
        start
    ;;
    stop)
        stop
    ;;
    restart)
        restart
    ;;
    status)
        if [ -f $PID ]; then
		echo "Git is running"
	else 
		echo "Git is NOT running"
	fi
        RETVAL=$?
    ;;
    *)

    echo "Usage: $prog {start|stop|restart|status}"
    exit 3
esac

exit $RETVAL
