#!/bin/bash
#
# ____  _____ ____ ____  _   _ ___ _____ _____
#/ ___|| ____/ ___/ ___|| | | |_ _|_   _| ____|
#\___ \|  _|| |   \___ \| | | || |  | | |  _|
# ___) | |__| |___ ___) | |_| || |  | | | |___
#|____/|_____\____|____/ \___/|___| |_| |_____|
#       CPU-TEMPERATURE-MONITOR
#
#DO NOT CHANGE MANUALLY:
#Use the installer
mysqluser='user'
mysqlpass='pass'
hostname='host'
ipaddr="127.0.0.1"
#########################
#ASCII Colours
red='\033[0;31m'
green='\033[0;32m'
nc='\033[0m'
#
temptemp="/root/scripts/SECSUITE/inframon/temperaturefiles/tempfile.txt"
tempcores="/root/scripts/SECSUITE/inframon/temperaturefiles/tempcores.csv"
coresrefined="/root/scripts/SECSUITE/inframon/temperaturefiles/coresrefined.csv"
corelines="/root/scripts/SECSUITE/inframon/temperaturefiles/corelines.txt"
dbfile="/root/scripts/SECSUITE/inframon/temperaturefiles/dbfile.txt"
dbidnums="/root/scripts/SECSUITE/inframon/temperaturefiles/dbidnums.txt"
basedir="/root/scripts/SECSUITE/inframon/temperaturefiles"
qry1="/root/scripts/SECSUITE/inframon/temperaturefiles/qry1.txt"
qry2="/root/scripts/SECSUITE/inframon/temperaturefiles/qry2.txt"
qry3="/root/scripts/SECSUITE/inframon/temperaturefiles/qry3.txt"
qry4="/root/scripts/SECSUITE/inframon/temperaturefiles/qry4.txt"
qry5="/root/scripts/SECSUITE/inframon/temperaturefiles/qry5.txt"
#
#Get the Temps
sensors >> $temptemp
#Get only the temp values
cat $temptemp | grep -E "Core" >> $tempcores
#Refine
sed -i 's/,/ /g' $tempcores
sed -r 's/.{32}$//' $tempcores > $coresrefined
sed -i 's/(//g' $coresrefined
sed -i 's/)//g' $coresrefined
sed -i 's/+//g' $coresrefined
sed -i 's/°C//g' $coresrefined
#cat $coresrefined
#echo "---------"
#wc -l $coresrefined > $corelines
cat $coresrefined | wc -l > $corelines
#cat $corelines
#sed -i "s/\/root\/scripts\/SECSUITE\/inframon\/temperaturefiles\/coresrefined.csv\//g" $corelines
#echo "Existing Cores on Machine:"
#cat $corelines
localcores=$(cat $corelines)
rm $tempcores $temptemp
#echo ""
#Check if table exists in the status db:
#echo "Checking for previous installs..."
mysqlshow --user="$mysqluser" --password="$mysqlpass" status >> $dbfile 2>/dev/null
if grep -q "temperature-$hostname" "/root/scripts/SECSUITE/inframon/temperaturefiles/dbfile.txt"; then
        #printf "${green} Table 'status.temperature-$hostname' exists, continuing...${nc}\n"
        table="$(cat /root/scripts/SECSUITE/inframon/temperaturefiles/resources/sc.txt)temperature-$hostname$(cat /root/scripts/SECSUITE/inframon/temperaturefiles/resources/sc.txt)"
        echo "mysql --user='$mysqluser' --password='$mysqlpass' -e " >> $qry1
        echo '"' >> $qry1
        echo "USE status;INSERT INTO " >> $qry1
        echo "$table" >> $qry1
        echo " " >> $qry1
        echo 'VALUES (' >> $qry1
        #echo "Getting new ID for $hostname..."
        #Get the ID numbers from the current database, add one, and use that as the ID for the new one.
        mysql -h"$ipaddr" -D'status' --user="$mysqluser" --password="$mysqlpass" -e "SELECT ID FROM \`temperature-$hostname\`;" > $dbidnums 2>/dev/null
        i=$(awk '/./{line=$0} END{print line}' $dbidnums)
        #Add one to make it acceptable
        ((i++))
        #printf "+ The new ID has been generated: ${green} $i ${nc}\n"
        echo "'$i', '$hostname', " >> $qry1
        tr -d "\n" < $qry1 > $qry2
        sed -i 's/:       /\,      /g' $coresrefined
        sed -i 's/\,//g' $coresrefined
        input=$coresrefined
        while IFS= read -r line
        do
          echo "$line" | awk '{print "'\''"$3"'\''" " ," }' >> $qry2
        done < "$input"
        tr -d "\n" < $qry2 >> $qry3
        grep -Po '.*(?=,$)' $qry3 >> $qry4
        echo ');" 2>/dev/null' >> $qry4
        echo "" >> $qry4
        tr -d "\n" < $qry4 >> $qry5
        echo "" >> $qry5
        mv $qry5 $basedir/insertintodb.sh
        mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status;TRUNCATE \`temperature-$hostname\`;" 2>/dev/null
        chmod 755 $basedir/insertintodb.sh ; bash $basedir/insertintodb.sh
        rm $qry1 $qry2 $qry3 $qry4 $basedir/insertintodb.sh $dbidnums $corelines
        #mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status;SELECT * FROM \`temperature-$hostname\`;" 2>/dev/null
        mysqlshow --user="$mysqluser" --password="$mysqlpass" status >> $dbfile 2>/dev/null
        if grep -q "hist-temperature-$hostname" "$dbfile"; then
                mysql --user=$mysqluser --password=$mysqlpass -e "USE status; INSERT INTO \`hist-temperature-$hostname\` SELECT *, RAND(), CURRENT_TIMESTAMP() FROM \`temperature-$hostname\`;" 2>/dev/null
                #mysql --user=$mysqluser --password=$mysqlpass -e "USE status; SELECT * FROM \`hist-temperature-$hostname\`;" 2>/dev/null
                rm $coresrefined
            else
                table="$(cat /root/scripts/SECSUITE/inframon/temperaturefiles/resources/sc.txt)hist-temperature-$hostname$(cat /root/scripts/SECSUITE/inframon/temperaturefiles/resources/sc.txt)"
                echo "mysql --user='$mysqluser' --password='$mysqlpass' -e " >> $qry1
                echo '"' >> $qry1
                echo "USE status;CREATE TABLE IF NOT EXISTS " >> $qry1
                echo "$table" >> $qry1
                echo " " >> $qry1
                echo "(id int(11) NOT NULL, hostname varchar(255) DEFAULT NULL, " >> $qry1
                sed -i 's/:       /\,      /g' $coresrefined
                sed -i 's/Core /Core/g' $coresrefined
                echo ''
                sed -i 's/\,//g' $coresrefined
                input=$coresrefined
                while IFS= read -r line
                do
                  echo "$line" | awk '{print $1 " varchar(255) NOT NULL," }' >> $qry1
                done < "$input"
                echo "random varchar(255) NOT NULL, importtime varchar(255) NOT NULL," >> $qry1
                echo 'PRIMARY KEY (random));" 2>/dev/null'>> $qry1
                echo ''
                tr -d '\n' < $qry1 >> $qry2
                echo "" >> $qry2

                mv $qry2 $basedir/create-hist-table.sh ; chmod 755 $basedir/create-hist-table.sh ; bash $basedir/create-hist-table.sh ; rm $qry1 $basedir/create-hist-table.sh $coresrefined
                #
                mysql --user=$mysqluser --password=$mysqlpass -e "USE status; INSERT INTO \`hist-temperature-$hostname\` SELECT *, RAND(), CURRENT_TIMESTAMP() FROM \`temperature-$hostname\`;" 2>/dev/null
                #mysql --user=$mysqluser --password=$mysqlpass -e "USE status; SELECT * FROM \`hist-temperature-$hostname\`;"

        fi
fi
if ! grep -q "temperature-$hostname" "/root/scripts/SECSUITE/inframon/temperaturefiles/dbfile.txt"; then
        #printf "${red} Table 'status.temperature-$hostname' Doesn't exist...${nc}\n"
        table="$(cat /root/scripts/SECSUITE/inframon/temperaturefiles/resources/sc.txt)temperature-$hostname$(cat /root/scripts/SECSUITE/inframon/temperaturefiles/resources/sc.txt)"
        echo "mysql --user='$mysqluser' --password='$mysqlpass' -e " >> $qry1
        echo '"' >> $qry1
        echo "USE status;CREATE TABLE IF NOT EXISTS " >> $qry1
        echo "$table" >> $qry1
        echo " " >> $qry1
        echo "(id int(11) NOT NULL, hostname varchar(255) DEFAULT NULL, " >> $qry1
        sed -i 's/:       /\,      /g' $coresrefined
        sed -i 's/Core /Core/g' $coresrefined
        echo ''
        #echo "Listing Cores..."
        #cat coresrefined.csv
        sed -i 's/\,//g' $coresrefined
        input=$coresrefined
        while IFS= read -r line
        do
          echo "$line" | awk '{print $1 " varchar(255) NOT NULL," }' >> $qry1
        done < "$input"
        echo 'PRIMARY KEY (id));" 2>/dev/null'>> $qry1
        echo ''
        tr -d "\n" < $qry1 > $qry2
        echo "" >> $qry2
        #cat qry2.txt
        mv $qry2 $basedir/createtemptbl.sh
        chmod 755 $basedir/createtemptbl.sh ; bash $basedir/createtemptbl.sh
        # mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status;DESCRIBE \`temperature-$hostname\`;" 2>/dev/null
        rm $qry1 $basedir/createtemptbl.sh
        #
        mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status;DESCRIBE \`temperature-$hostname\`;" >> $basedir/temphostname.txt 2>/dev/null
        cat $basedir/temphostname.txt | grep "Core" >> $basedir/corefile.txt
        cat $basedir/corefile.txt | awk '{print $1}' >> $basedir/corenumtbl.txt
        wc -l $basedir/corenumtbl.txt > $basedir/corenums.txt
        sed -i 's/corenumtbl.txt//g' $basedir/corenums.txt
        dbcores=$(cat $basedir/corenums.txt)
        rm $basedir/temphostname.txt $basedir/corefile.txt $basedir/corenumtbl.txt $basedir/corenums.txt $basedir/corelines.txt $coresrefined
        #echo "Cores on Machine:"
        #echo $localcores
        #echo "Cores in temperature-$hostname"
        #echo $dbcores
fi
rm $dbfile
#
if [ "$localcores" = "$dbcores" ]; then
        table="$(cat /root/scripts/SECSUITE/inframon/temperaturefiles/resources/sc.txt)temperature-$hostname$(cat /root/scripts/SECSUITE/inframon/temperaturefiles/resources/sc.txt)"
        echo "mysql --user='$mysqluser' --password='$mysqlpass' -e " >> $qry1
        echo '"' >> $qry1
        echo "USE status;INSERT INTO " >> $qry1
        echo "$table" >> $qry1
        echo " " >> $qry1
        echo 'VALUES (' >> $qry1
        #echo "Getting new ID for $hostname..."
        #Get the ID numbers from the current database, add one, and use that as the ID for the new one.
        mysql -h"$ipaddr" -D'status' --user="$mysqluser" --password="$mysqlpass" -e "SELECT ID FROM \`temperature-$hostname\`;" > $dbidnums 2>/dev/null
        i=$(awk '/./{line=$0} END{print line}' $dbidnums)
        #Add one to make it acceptable
        ((i++))
        #printf "+ The new ID has been generated: ${green} $i ${nc}\n"
        echo "'$i', '$hostname', " >> $qry1
        tr -d "\n" < $qry1 > $qry2
        sed -i 's/:       /\,      /g' $coresrefined
        sed -i 's/\,//g' $coresrefined
        input=$coresrefined
        while IFS= read -r line
        do
          echo "$line" | awk '{print "'\''"$2"'\''" " ," }' >> $qry2
        done < "$input"
        tr -d "\n" < $qry2 >> $qry3
        grep -Po '.*(?=,$)' $qry3 >> $qry4
        echo ');" 2>/dev/null' >> $qry4
        echo "" >> $qry4
        echo ""
        tr -d "\n" < $qry4 >> $qry5
        echo "" >> $qry5
        mv $qry5 $basedir/insertintodb.sh
        chmod 755 $basedir/insertintodb.sh ; bash $basedir/insertintodb.sh
        rm $qry1 $qry2 $qry3 $qry4 $basedir/insertintodb.sh $basedir/coresrefined.csv $dbidnums
        # mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status;SELECT * FROM \`temperature-$hostname\`;" 2>/dev/null
fi
exit
