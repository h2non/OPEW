#!/bin/bash
#
# This script is part of the OPEW project <http://opew.sf.net>
# 
# Very simple init script for Redis server.
# @see ../etc/redis.conf
#
#

. /opt/opew/stack/scripts/setenv.sh

OPEW="/opt/opew/stack/redis"
EXEC="$OPEW/bin/redis-server"
CLIEXEC="$OPEW/bin/redis-cli"
CONF="$OPEW/etc/redis.conf"
REDISPORT=`grep -E "^ *port +([0-9]+) *$" "$CONF" | grep -Eo "[0-9]+"`
PIDFILE="$OPEW/redis.pid"
LOG="$OPEW/log/redis_$REDISPORT.log"

case "$1" in
    start)
        if [ -f $PIDFILE ]
	then
                echo "$0 : Redis is already running..."
        else
                echo -n "$0 : Starting Redis server on port $REDISPORT..."
                `$EXEC $CONF >> $LOG` & 
		sleep 1
		echo " done! You can see the output log in: $LOG"
        fi
        ;;
    stop)
	if [ ! -f $PIDFILE ]
        then
                echo "$0 : Redis is not running..."
        else
		PID=$(cat $PIDFILE)
		echo -n "$0 : Stopping... "
                $CLIEXEC -p $REDISPORT shutdown
                while [ -x /proc/${PID} ]
                do
                    echo -n "Waiting for Redis to shutdown... "
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
        echo "Usage: $0 (start|stop|restart)"
        ;;
esac

exit 
