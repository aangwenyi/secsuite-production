#!/bin/bash
#You will need to edit the HOSTNAME and your email address on both following lines;
mv /root/scripts/SECSUITE/system_monitor/large.log /root/scripts/SECSUITE/system_monitor/HOSTNAME-quarter-hour.log
echo "Please see attached file" | mutt -a "/root/scripts/SECSUITE/system_monitor/HOSTNAME-quarter-hour.log" -s "HOSTNAME Hourly System Monitor" -- you@domain.tld
exit
