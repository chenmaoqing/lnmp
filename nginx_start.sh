#! /bin/bash
#


# Source function library.
. /etc/init.d/functions

# Progran name
prog="nginx"

start() {
      echo -n $"Starting $prog: "
   	 if [ -e /var/lock/nginx.lock ]; then
   	     if [ -e /var/run/nginx/nginx.pid ] && [ -e /proc/`cat /var/run/nginx/nginx.pid ` ]; then
            echo -n $"cannot start $prog: nginx is already running."
            failure $"cannot start $prog: nginx is already running."
            echo
            return 1
        fi
    fi
    /opt/webserver/nginx/sbin/nginx
    RETVAL=$?
    [ $RETVAL -eq 0 ] && success $"$prog start" || failure $"$prog start"
    [ $RETVAL -eq 0 ] && touch /var/lock/nginx.lock
    echo
    return $RETVAL
}

stop() {
    echo -n $"Stopping $prog: "
    if [ ! -e /var/lock/nginx.lock ] || [ ! -e /var/run/nginx/nginx.pid  ]; then
        echo -n $"cannot stop $prog: nginx is not running."
        failure $"cannot stop $prog: nginx is not running."
        echo
        return 1
    fi
    PID=`cat /var/run/nginx/nginx.pid `
    if checkpid $PID 2>&1; then
        # TERM first, then KILL if not dead
        kill -TERM $PID >/dev/null 2>&1
        usleep 100000
        if checkpid $PID && sleep 1 && checkpid $PID && sleep 3 && checkpid $PID; then
            kill -KILL $PID >/dev/null 2>&1
            usleep 100000
        fi
    fi
    checkpid $PID
    RETVAL=$((! $?))
    [ $RETVAL -eq 0 ] && success $"$prog shutdown" || failure $"$prog shutdown"
    [ $RETVAL -eq 0 ] && rm -f /var/lock/nginx.lock;
    echo
    return $RETVAL
}

status() {
    status $prog
    RETVAL=$?
}

restart() {
    stop
    start
}

reload() {
    echo -n $"Reloading $prog: "
    if [ ! -e /var/lock/nginx.lock ] || [ ! -e /var/run/nginx/nginx.pid  ]; then
        echo -n $"cannot reload $prog: nginx is not running."
        failure $"cannot reload $prog: nginx is not running."
        echo
        return 1
    fi
    kill -HUP `cat /var/run/nginx/nginx.pid ` >/dev/null 2>&1
    RETVAL=$?
    [ $RETVAL -eq 0 ] && success $"$prog reload" || failure $"$prog reload"
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
    restart
    ;;
reload)
    reload
    ;;
status)
    status
    ;;
link)
	netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
	;;
ps)
	ps -ef | grep nginx | wc -l
	;;
condrestart)
    [ -f /var/lock/nginx.lock ] && restart || :
    ;;
t)
    /opt/webserver/nginx/sbin/nginx -t 
    ;;
configtest)
       /opt/webserver/nginx/sbin/nginx -t
      ;;
 *)
    echo $"Usage: $0 {start|stop|status|reload|restart|condrestart|configtest|link|ps}"
    exit 1
esac
