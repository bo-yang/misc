#!/bin/sh

# This is a simple script to monitor potential memory leak.
# For more details, please refer to: http://www.bo-yang.net/2015/03/30/debug-kernel-space-memory-leak

MAX_SIZE=20000000
MON_FILE=/path/to/monitor_output_$(uname -n)
while true
do
    date >> $MON_FILE
    cat /proc/meminfo >> $MON_FILE
    echo "----------------------" >> $MON_FILE
    cat /proc/slabinfo >> $MON_FILE
    echo "----------------------" >> $MON_FILE
    ps -o pid,comm,stat,time,rss,vsz >> $MON_FILE
    echo "++++++++++++++++++++++" >> $MON_FILE
    fsize=`ls -l $MON_FILE | awk '{print $5}'`
    if [ $fsize -gt $MAX_SIZE ]; then
        suffix=`cat /proc/uptime | cut -d" " -f1`
        mv $MON_FILE $MON_FILE.$suffix
        #TODO: upload file to TFTP server or cloud
    fi
    sleep 3600 # 1 hour
done
