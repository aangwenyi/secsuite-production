#!/bin/bash
#MySQL Creds
mysqluser="user"
mysqlpass='pass'
#Get Current Amount of Configured Assets
mysql --user=$mysqluser --password=$mysqlpass -e "use status;SELECT * FROM cpu;" > cpu-loads.txt 2>/dev/null
#echo "Current CPU Loads: "
#cat cpu-loads.txt
#echo ''
#Remove First Line
sed -i '1d' cpu-loads.txt # GNU sed only
sed -e 's/\s\+/ ,       /g' cpu-loads.txt > loadswithcommas.txt
#Set Thresholds Below;
cpuonemin=$(cat loadswithcommas.txt | awk '{print $5}')
cpuonemaxthreshold="2.0"
if (( $(echo "$cpuonemin > $cpuonemaxthreshold" | bc -l) )); then
        #Prepare Message
        message="CPU-Load-One-Min_is_Above_the_Set_Threshold:=$(cat loadswithcommas.txt | awk '{print $5}')_On_$(date '+%m-%d-%Y')_At_$(date | awk '{print $4}')"
        bash notification-sender-tg.sh $(echo $message)
fi
#Set Thresholds Below;
cputenmin=$(cat loadswithcommas.txt | awk '{print $7}')
cputenmaxthreshold="1.8"
if (( $(echo "$cputenmin > $cputenmaxthreshold" | bc -l) )); then
        #Prepare Message
        message1="CPU-Load-Ten-Min_is_Above_the_Set_Threshold:=$(cat loadswithcommas.txt | awk '{print $7}')_On_$(date '+%m-%d-%Y')_At_$(date | awk '{print $4}')"
        bash notification-sender-tg.sh $(echo $message1)
fi
#Set Thresholds Below;
cpufifmin=$(cat loadswithcommas.txt | awk '{print $9}')
cpufifmaxthreshold="1.2"
if (( $(echo "$cpufifmin > $cpufifmaxthreshold" | bc -l) )); then
        #Prepare Message
        message2="CPU-Load-Fifteen-Min_is_Above_the_Set_Threshold:=$(cat loadswithcommas.txt | awk '{print $9}')_On_$(date '+%m-%d-%Y')_At_$(date | awk '{print $4}')"
        bash notification-sender-tg.sh $(echo $message2)
fi
rm cpu-loads.txt loadswithcommas.txt
exit
