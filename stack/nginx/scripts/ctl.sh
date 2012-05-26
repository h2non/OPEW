#!/bin/bash
# 
# Nginx ctl script
#

export NGINX_INSTALLDIR=/opt/opew/stack/nginx
export INSTALLDIR=/opt/opew/stack
NGINX_PIDFILE="$NGINX_INSTALLDIR/logs/nginx.pid"
NGINX_PID=""
NGINX="$NGINX_INSTALLDIR/sbin/nginx"
NGINX_STATUS=""
NGINX_BIN=nginx.bin

if [ -r "$INSTALLDIR/scripts/setenv.sh" ]; then
. "$INSTALLDIR/scripts/setenv.sh"
fi

get_pid() {
    PID=""
    PIDFILE=$1
    # check for pidfile                                                                                                      
    if [ -f "$PIDFILE" ] ; then
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

get_nginx_pid() {
    get_pid $NGINX_PIDFILE
    if [ ! "$PID" ]; then
        return
    fi
    if [ "$PID" -gt 0 ]; then
        NGINX_PID=$PID
    fi
}

is_nginx_running() {
    get_nginx_pid
    is_service_running $NGINX_PID
    RUNNING=$?
    if [ "$RUNNING" -eq 0 ]; then
        NGINX_STATUS="Nginx not running"
    else
        NGINX_STATUS="Nginx already running"
    fi
    return $RUNNING
}

start_nginx() {
    is_nginx_running
    RUNNING=$?
    if [ "$RUNNING" -eq 1 ]; then
        echo "$0 $ARG: Nginx (pid $NGINX_PID) already running"
    else
         $NGINX
         COUNTER=20
         while [ $RUNNING -eq 0 ] && [ $COUNTER -ne 0 ]; do
             COUNTER=`expr $COUNTER - 1`
             sleep 3
             is_nginx_running
             RUNNING=$?
         done
         get_nginx_pid
         if [ "$NGINX_PID" -gt 0 ]; then
             echo "$0 $ARG: Nginx started (default port 8080)"
         else
             echo "$0 $ARG: Nginx could not be started"
             ERROR=3
         fi
    fi
}

stop_nginx() {
    NO_EXIT_ON_ERROR=$1
    is_nginx_running
    RUNNING=$?

    if [ "$RUNNING" -eq 0 ]; then
        echo "$0 $ARG: $NGINX_STATUS"
        if [ "x$NO_EXIT_ON_ERROR" != "xno_exit" ]; then
            exit
        else
            return
        fi
    fi
    get_nginx_pid
    if kill $NGINX_PID ; then
        echo "$0 $ARG: Nginx stopped"
    else
        echo "$0 $ARG: Nginx could not be stopped"
        ERROR=4
    fi
}

cleanpid() {
    rm -f $NGINX_PIDFILE
}

case $1 in
    start)
	start_nginx
	;;
    stop)
	stop_nginx
	;;
    cleanpid)
	cleanpid
	;;
    status)
    is_nginx_running
    echo "$NGINX_STATUS"
esac

exit 0
