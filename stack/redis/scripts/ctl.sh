#!/bin/bash
#
# This script is part of the OPEW project <http://opew.sf.net>
# 
# Very simple init script for Redis server.
# This script uses UNIX 'ps' tool command directly in order to get the process PID, not PID files
# @see ../etc/redis.conf
#
#

. /opt/opew/stack/scripts/setenv.sh

OPEW="/opt/opew/stack/redis"
EXEC="$OPEW/bin/redis-server"
CLIEXEC="$OPEW/bin/redis-cli"
CONF="$OPEW/etc/redis.conf"
REDISPORT=`grep -E "^ *port +([0-9]+) *$" "$CONF" | grep -Eo "[0-9]+"`
#PIDFILE=`grep -E "^ *pidfile +([a-z0-9/.]) *$" "$CONF" | grep -Eo "[a-z0-9/.]+"`
#echo "PID FILE -> " $PIDFILE
PIDFILE="$OPEW/redis.pid"
LOG="$OPEW/log/redis_$REDISPORT.log"

case "$1" in
    start)
        if [ -f $PIDFILE ]
	then
                echo "Redis is already running..."
        else
                echo -n "Starting Redis server on port $REDISPORT..."
                `$EXEC $CONF >> $LOG` & 
		sleep 1
		echo " done!"
		echo "You can see the output log in: $LOG"
        fi
        ;;
    stop)
	if [ ! -f $PIDFILE ]
        then
                echo "Redis is not running..."
        else
		PID=$(cat $PIDFILE)
		echo -n "Stopping ... "
                $CLIEXEC -p $REDISPORT shutdown
                while [ -x /proc/${PID} ]
                do
                    echo -n "Waiting for Redis to shutdown ..."
                    sleep 1
		    kill -9 $PID 
                done
		sleep 1
                echo "Redis stopped!"
        fi
        ;;
    restart)

	${0} stop
	sleep 1
	${0} start

      	;;
    *)
        echo "Please use (start|stop|restart) as first argument"
        ;;
esac

exit 
