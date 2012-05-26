#!/bin/bash
#
# Memcached Ctl Script
#

export MEMCACHED_INSTALLDIR=/opt/opew/stack/memcached
export MEMCACHED_PORT=11211
export INSTALLDIR=/opt/opew/stack
MEMCACHED_USER=opew
MEMCACHED_PIDFILE="$MEMCACHED_INSTALLDIR/tmp/memcached.pid"
MEMCACHED_PID=""
MEMCACHED_START="$MEMCACHED_INSTALLDIR/bin/memcached -l localhost -p $MEMCACHED_PORT -P $MEMCACHED_PIDFILE -u $MEMCACHED_USER -d "
MEMCACHED_STATUS=""

if [ -r "$INSTALLDIR/scripts/setenv.sh" ]; then
. "$INSTALLDIR/scripts/setenv.sh"
fi

get_pid() {
    PID=""
    PIDFILE=$1
    # check for pidfile                                                                                                      
    if [ -f $PIDFILE ] ; then
        exec 6<&0
        exec < $PIDFILE
        read pid
        PID=$pid
        exec 0<&6 6<&-
    fi
}

is_service_running() {
    PID=$1
    if [ "x$PID" != "x" ] && kill -0 $PID 2>/dev/null ; then
        RUNNING=1
    else
        RUNNING=0
    fi
    return $RUNNING
}

get_memcached_pid() {
    get_pid $MEMCACHED_PIDFILE
    if [ ! $PID ]; then
        return 0
    fi
    if [ "$PID" -gt 0 ]; then
        MEMCACHED_PID=$PID
    fi
}

is_memcached_running() {
    get_memcached_pid
    is_service_running $MEMCACHED_PID
    RUNNING=$?
    if [ $RUNNING -eq 0 ]; then
        MEMCACHED_STATUS="Memcached not running"
    else
        MEMCACHED_STATUS="Memcached already running"
    fi
    return $RUNNING
}

start_memcached() {
    is_memcached_running
    RUNNING=$?
    if [ $RUNNING -eq 1 ]; then
        echo "$0 $ARG: Memcached (pid $MEMCACHED_PID) already running"
    else
         $MEMCACHED_START &
         sleep 5
         get_memcached_pid
         if [ ! -z "$MEMCACHED_PID" ] && [ "$MEMCACHED_PID" -gt 0 ]; then
             echo "$0 $ARG: Memcached started"
         else
             echo "$0 $ARG: Memcached could not be started"
             ERROR=3
         fi
    fi
}

stop_memcached() {
    NO_EXIT_ON_ERROR=$1
    is_memcached_running
    RUNNING=$?

    if [ $RUNNING -eq 0 ]; then
        echo "$0 $ARG: $MEMCACHED_STATUS"
        if [ "x$NO_EXIT_ON_ERROR" != "xno_exit" ]; then
            exit
        else
            return
        fi
    fi
    get_memcached_pid
    if kill $MEMCACHED_PID ; then
        rm $MEMCACHED_PIDFILE
        echo "$0 $ARG: Memcached stopped"
    else
        echo "$0 $ARG: Memcached could not be stopped"
        ERROR=4
    fi
}

cleanpid() {
    rm -f $MEMCACHED_PIDFILE
}

case $1 in
    start)
	start_memcached
	;;
    stop)
	stop_memcached
	;;
    cleanpid)
	cleanpid
	;;
    status)
    is_memcached_running
    echo "$MEMCACHED_STATUS"
esac

exit 0
