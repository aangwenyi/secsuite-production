#!/bin/bash
#
#Optional script if you wish to move your logs to a processing server; 
#You will need to edit "SERVERNAME" below to the corresponding hostname & the SSH credentials on line 7.
#
mv /root/scripts/SECSUITE/system_monitor/large.log /root/scripts/SECSUITE/system_monitor/SERVERNAME-Hourly-System-Monitor.log
rsync -avz /root/scripts/SECSUITE/system_monitor/SERVERNAME-Hourly-System-Monitor.log user@processing-server:/root/scripts/SECSUITE/SERVERNAME/systemlogs/
mv /root/scripts/SECSUITE/system_monitor/SERVERNAME-Hourly-System-Monitor.log /root/scripts/SECSUITE/system_monitor/logs/SERVERNAME-Syslog-Generated-On-$(date "+%Y.%m.%d-%H.%M.%S").log
exit
