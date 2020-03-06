#!/bin/bash
#MySQL Creds
mysqluser="user"
mysqlpass='pass'
#Get Current Amount of Configured Assets
mysql --user=$mysqluser --password=$mysqlpass -e "use status;SELECT * FROM apachestatus;" > apachestatus.txt 2>/dev/null

logfile='/root/scripts/SECSUITE/inframon/notifs/apache/apache-log.txt'

echo "" >> $logfile
echo "'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
echo "" >> $logfile

echo "Beginning Apache Server Checks at: $(date)" >> $logfile

if grep -q "Active: active" "apachestatus.txt"; then
        echo "Apache is Active at: $(date)" >> $logfile
    else
        #Apache is Inactive
        file="/root/scripts/SECSUITE/inframon/notifs/apache/downtime.txt"
        if [ -f "$file" ]
        then
                echo "Downtime is persisting. Continuing monitor at: $(date)" >> $logfile
        else
                echo "$(date '+%m-%d-%Y')_At_$(date | awk '{print $4}')" > downtime.txt
                echo "Downtime has been detected at: $(date)" >> $logfile
        fi
fi
lastrun="/root/scripts/SECSUITE/inframon/notifs/apache/last-run.txt"
if [ -f "$lastrun" ]
then
        echo "Last Run Exists. Continuing monitor at: $(date)" >> $logfile
else
        echo "Creating $lastrun at: $(date)" >> $logfile
        touch /root/scripts/SECSUITE/inframon/notifs/apache/last-run.txt
        lastruncheck="/root/scripts/SECSUITE/inframon/notifs/apache/last-run.txt"
        if [ -f "$lastruncheck" ]
        then
        echo "Last Run Has been Created at: $(date)" >> $logfile
        else
        echo "There was an error creating $lastrun at: $(date)" >> $logfile
        fi
fi
#Check if Apache was down:
if grep -q "Offline" "last-run.txt"; then
        #Apache was down
        #Now check if it is back up:
        if grep -q "Active: active" "apachestatus.txt"; then
                #Prepare Message
                status=$(cat apachestatus.txt | grep -E " Active ")
                message="Apache_Server_Is_Back_Up!"
                bash notification-sender-tg-active.sh $(echo $message)
                echo "Notification of Uptime Confirmation sent at: $(date)" >> $logfile
                rm downtime.txt
        fi
        #Now check if it is still down:
        if grep -q "Offline" "apachestatus.txt"; then
                #Prepare Message
                status=$(cat apachestatus.txt | grep -E " Active ")
                downtime=$(cat $file)
                message="Apache_Server_Has_Been_Down_Since_$(echo $downtime)!!"
                echo "Notification of Recurring Downtime Detection sent at: $(date)" >> $logfile
                bash notification-sender-tg-inactive.sh $(echo $message)
        fi
    else
        #Apache was up
        #Now check if it is down:
        if grep -q "Offline" "apachestatus.txt"; then
                #Prepare Message
                status=$(cat apachestatus.txt | grep -E " Active ")
                downtime=$(cat $file)
                message="ALERT-Apache_Server_Has_Gone_Down_At_$(echo $downtime)!!"
                echo "Notification of Primary Downtime Detection sent at: $(date)" >> $logfile
                bash notification-sender-tg-inactive.sh $(echo $message)
        fi
        #Now check if it is still up:
        if grep -q "Active: active" "apachestatus.txt"; then
                #Prepare Message
                status=$(cat apachestatus.txt | grep -E " Active ")
                message="Apache_Server_Is_Running_Normally!"
                bash notification-sender-tg-active.sh $(echo $message)
                echo "Notification of Recurring Uptime Confirmation sent at: $(date)" >> $logfile
        fi
fi
cat apachestatus.txt > last-run.txt
rm apachestatus.txt
exit
