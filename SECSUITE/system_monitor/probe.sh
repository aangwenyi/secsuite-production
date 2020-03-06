#!/bin/bash
#
#Les Variables:
largelog='/root/scripts/SECSUITE/system_monitor/large.log'
logfile='/root/scripts/SECSUITE/system_monitor/temp.log'
############
#Begin
#
echo '' >> $logfile
echo '+++++++++++++++' >> $logfile
echo '' >> $logfile
echo 'Begginning Monitor at: ' $(date) >> $logfile
uname -a >> $logfile
echo '' >> $logfile
echo 'Heavy Processes at:' $(date) >> $logfile
ps aux | sort -nrk 3,3 | head -n 20 >> $logfile
echo '' >> $logfile
echo '***' >> $logfile
echo '' >> $logfile
echo 'Disk Spaces at: ' $(date) >> $logfile
df -h >> $logfile
echo '' >> $logfile
echo '***' >> $logfile
echo '' >> $logfile
echo 'Current connected users / ip at:' $(date) >> $logfile
w >> $logfile
echo '' >> $logfile
echo '***' >> $logfile
cat /root/scripts/SECSUITE/system_monitor/temp.log >> /root/scripts/SECSUITE/system_monitor/large.log
rm $logfile
exit
