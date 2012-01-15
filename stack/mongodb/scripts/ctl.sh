#!/bin/bash
#
# mongodb     Startup script for the mongodb server
#
# chkconfig: - 64 36
# description: MongoDB Database Server
#
# processname: mongodb
#

# Source function library

prog="mongod.lock"
mongod="/opt/opew/stack/mongodb/bin/mongod"
RETVAL=0

start() {
	if [ ! -f /opt/opew/stack/mongodb/data/*.lock ]; then
	echo -n "Starting mongodb: "
	$mongod --config /opt/opew/stack/mongodb/etc/mongodb.conf 2>&1 >>/opt/opew/stack/mongodb/log/mongodb.log
	sleep 1
        echo -n " done!"
	else 
	echo -n "mongodb is already running with PID "`cat /opt/opew/stack/mongodb/data/*.lock`
	fi
	RETVAL=$?
	echo
	[ $RETVAL -eq 0 ] && touch /opt/opew/stack/mongodb/data/$prog
	return $RETVAL
}

stop() {
	if [ -f /opt/opew/stack/mongodb/data/*.lock ]; then
	echo -n "Stopping mongodb: "
	kill `cat /opt/opew/stack/mongodb/data/*.lock`
	else 
	echo -n "mondodb is NOT running"
	fi
	RETVAL=$?
	sleep 1
	echo -n " done!"
	echo
	[ $RETVAL -eq 0 ] && rm -f /opt/opew/stack/mongodb/data/$prog
	return $RETVAL
}

reload() {
	echo -n $"Reloading mongodb: "
	killall $prog -HUP
	RETVAL=$?
	echo
	return $RETVAL
}

case "$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	restart)
		stop
		start
		;;
	condrestart)
		if [ -f /opt/opew/stack/mongodb/data/$prog ]; then
			stop
			start
		fi
		;;
	reload)
		reload
		;;
	status)
		if [ -f /opt/opew/stack/mongodb/data/$prog ]; then
			echo "mongodb is running"
		else
			echo "mongodb is NOT running"
		fi
		RETVAL=$?
		;;
	*)
		echo $"Usage: $0 {start|stop|restart|condrestart|reload|status}"
		RETVAL=1
esac

exit $RETVAL
