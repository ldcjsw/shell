#/bin/sh
pid=`ps -ef|grep engine_db_monitor.sh|grep -v grep|awk '{print $2}'`
kill -9 $pid
