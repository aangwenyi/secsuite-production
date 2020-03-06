#!/bin/bash
#
# ____  _____ ____ ____  _   _ ___ _____ _____
#/ ___|| ____/ ___/ ___|| | | |_ _|_   _| ____|
#\___ \|  _|| |   \___ \| | | || |  | | |  _|
# ___) | |__| |___ ___) | |_| || |  | | | |___
#|____/|_____\____|____/ \___/|___| |_| |_____|
#       CPU-TEMPERATURE-MONITOR
#
mysqluser="USER"
mysqlpass="PASS"
hostname="HOST"
#ASCII Colours
red='\033[0;31m'
green='\033[0;32m'
nc='\033[0m'
#
#
#Get the Temps
sensors >> temptemp.txt
#Get only the temp values
cat temptemp.txt | grep -E "Core" >> tempcores.csv
#Refine
sed -i 's/,/ /g' tempcores.csv
sed -r 's/.{32}$//' tempcores.csv > coresrefined.csv
sed -i 's/(//g' coresrefined.csv
sed -i 's/)//g' coresrefined.csv
sed -i 's/+//g' coresrefined.csv
sed -i 's/°C//g' coresrefined.csv
#cat coresrefined.csv
#echo "---------"
wc -l coresrefined.csv > corelines.txt
sed -i 's/coresrefined.csv//g' corelines.txt
#echo "Existing Cores on Machine:"
#cat corelines.txt
localcores=$(cat corelines.txt)
rm tempcores.csv temptemp.txt
#echo ""
#Check if table exists in the status db:
#echo "Checking for previous installs..."
mysqlshow --user="$mysqluser" --password="$mysqlpass" status >> dbfile.txt 2>/dev/null
if grep -q "temperature-$hostname" "dbfile.txt"; then
        #printf "${green} Table 'status.temperature-$hostname' exists, continuing...${nc}\n"
        table="$(cat /root/scripts/SECSUITE/inframon/temperaturefiles/resources/sc.txt)temperature-$hostname$(cat /root/scripts/SECSUITE/inframon/temperaturefiles/resources/sc.txt)"
        echo "mysql --user='$mysqluser' --password='$mysqlpass' -e " >> qry1.txt
        echo '"' >> qry1.txt
        echo "USE status;INSERT INTO " >> qry1.txt
        echo "$table" >> qry1.txt
        echo " " >> qry1.txt
        echo 'VALUES (' >> qry1.txt
        #echo "Getting new ID for $hostname..."
        #Get the ID numbers from the current database, add one, and use that as the ID for the new one.
        mysql -h"$ipaddr" -D'status' --user="$mysqluser" --password="$mysqlpass" -e "SELECT ID FROM \`temperature-$hostname\`;" > dbidnums.txt 2>/dev/null
        i=$(awk '/./{line=$0} END{print line}' dbidnums.txt)
        #Add one to make it acceptable
        ((i++))
        #printf "+ The new ID has been generated: ${green} $i ${nc}\n"
        echo "'$i', '$hostname', " >> qry1.txt
        tr -d "\n" < qry1.txt > qry2.txt
        sed -i 's/:       /\,      /g' coresrefined.csv
        sed -i 's/\,//g' coresrefined.csv
        input="coresrefined.csv"
        while IFS= read -r line
        do
          echo "$line" | awk '{print "'\''"$3"'\''" " ," }' >> qry2.txt
        done < "$input"
        tr -d "\n" < qry2.txt >> qry3.txt
        grep -Po '.*(?=,$)' qry3.txt >> qry4.txt
        echo ');" 2>/dev/null' >> qry4.txt
        echo "" >> qry4.txt
        tr -d "\n" < qry4.txt >> qry5.txt
        echo "" >> qry5.txt
        mv qry5.txt insertintodb.sh
        mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status;TRUNCATE \`temperature-$hostname\`;" 2>/dev/null
        chmod 755 insertintodb.sh ; bash insertintodb.sh
        rm qry1.txt qry2.txt qry3.txt qry4.txt insertintodb.sh dbidnums.txt corelines.txt coresrefined.csv
        #mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status;SELECT * FROM \`temperature-$hostname\`;" 2>/dev/null
        mysqlshow --user="$mysqluser" --password="$mysqlpass" status >> dbfile.txt 2>/dev/null
        if grep -q "hist-temperature-$hostname" "dbfile.txt"; then
                mysql --user=$mysqluser --password=$mysqlpass -e "USE status; INSERT INTO \`hist-temperature-$hostname\` SELECT *, RAND(), CURRENT_TIMESTAMP() FROM \`temperature-$hostname\`;" 2>/dev/null
                #mysql --user=$mysqluser --password=$mysqlpass -e "USE status; SELECT * FROM \`hist-temperature-$hostname\`;" 2>/dev/null
                rm coresrefined.csv

            else

                table="$(cat /root/scripts/SECSUITE/inframon/temperaturefiles/resources/sc.txt)hist-temperature-$hostname$(cat /root/scripts/SECSUITE/inframon/temperaturefiles/resources/sc.txt)"
                echo "mysql --user='$mysqluser' --password='$mysqlpass' -e " >> qry1.txt
                echo '"' >> qry1.txt
                echo "USE status;CREATE TABLE IF NOT EXISTS " >> qry1.txt
                echo "$table" >> qry1.txt
                echo " " >> qry1.txt
                echo "(id int(11) NOT NULL, hostname varchar(255) DEFAULT NULL, " >> qry1.txt
                sed -i 's/:       /\,      /g' coresrefined.csv
                sed -i 's/Core /Core/g' coresrefined.csv
                echo ''
                sed -i 's/\,//g' coresrefined.csv
                input="coresrefined.csv"
                while IFS= read -r line
                do
                  echo "$line" | awk '{print $1 " varchar(255) NOT NULL," }' >> qry1.txt
                done < "$input"
                echo "random varchar(255) NOT NULL, importtime varchar(255) NOT NULL," >> qry1.txt
                echo 'PRIMARY KEY (random));" 2>/dev/null'>> qry1.txt
                echo ''
                tr -d '\n' < qry1.txt >> qry2.txt
                echo "" >> qry2.txt

                mv qry2.txt create-hist-table.sh ; chmod 755 create-hist-table.sh ; bash create-hist-table.sh ; rm qry1.txt create-hist-table.sh coresrefined.csv
                #
                mysql --user=$mysqluser --password=$mysqlpass -e "USE status; INSERT INTO \`hist-temperature-$hostname\` SELECT *, RAND(), CURRENT_TIMESTAMP() FROM \`temperature-$hostname\`;"
                #mysql --user=$mysqluser --password=$mysqlpass -e "USE status; SELECT * FROM \`hist-temperature-$hostname\`;"





        fi
fi

if ! grep -q "temperature-$hostname" "dbfile.txt"; then
        #printf "${red} Table 'status.temperature-$hostname' Doesn't exist...${nc}\n"
        table="$(cat /root/scripts/SECSUITE/inframon/temperaturefiles/resources/sc.txt)temperature-$hostname$(cat /root/scripts/SECSUITE/inframon/temperaturefiles/resources/sc.txt)"
        echo "mysql --user='$mysqluser' --password='$mysqlpass' -e " >> qry1.txt
        echo '"' >> qry1.txt
        echo "USE status;CREATE TABLE IF NOT EXISTS " >> qry1.txt
        echo "$table" >> qry1.txt
        echo " " >> qry1.txt
        echo "(id int(11) NOT NULL, hostname varchar(255) DEFAULT NULL, " >> qry1.txt
        sed -i 's/:       /\,      /g' coresrefined.csv
        sed -i 's/Core /Core/g' coresrefined.csv
        echo ''
        #echo "Listing Cores..."
        #cat coresrefined.csv
        sed -i 's/\,//g' coresrefined.csv
        input="coresrefined.csv"
        while IFS= read -r line
        do
          echo "$line" | awk '{print $1 " varchar(255) NOT NULL," }' >> qry1.txt
        done < "$input"
        echo 'PRIMARY KEY (id));" 2>/dev/null'>> qry1.txt
        echo ''
        tr -d "\n" < qry1.txt > qry2.txt
        echo "" >> qry2.txt
        #cat qry2.txt
        mv qry2.txt createtemptbl.sh
        chmod 755 createtemptbl.sh ; bash createtemptbl.sh
        # mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status;DESCRIBE \`temperature-$hostname\`;" 2>/dev/null
        rm qry1.txt createtemptbl.sh
        #
        mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status;DESCRIBE \`temperature-$hostname\`;" >> temphostname.txt 2>/dev/null
        cat temphostname.txt | grep "Core" >> corefile.txt
        cat corefile.txt | awk '{print $1}' >> corenumtbl.txt
        wc -l corenumtbl.txt > corenums.txt
        sed -i 's/corenumtbl.txt//g' corenums.txt
        dbcores=$(cat corenums.txt)
        rm temphostname.txt corefile.txt corenumtbl.txt corenums.txt corelines.txt
        #echo "Cores on Machine:"
        #echo $localcores
        #echo "Cores in temperature-$hostname"
        #echo $dbcores
fi
rm dbfile.txt
#
if [ "$localcores" = "$dbcores" ]; then
        table="$(cat /root/scripts/SECSUITE/inframon/temperaturefiles/resources/sc.txt)temperature-$hostname$(cat /root/scripts/SECSUITE/inframon/temperaturefiles/resources/sc.txt)"
        echo "mysql --user='$mysqluser' --password='$mysqlpass' -e " >> qry1.txt
        echo '"' >> qry1.txt
        echo "USE status;INSERT INTO " >> qry1.txt
        echo "$table" >> qry1.txt
        echo " " >> qry1.txt
        echo 'VALUES (' >> qry1.txt
        #echo "Getting new ID for $hostname..."
        #Get the ID numbers from the current database, add one, and use that as the ID for the new one.
        mysql -h"$ipaddr" -D'status' --user="$mysqluser" --password="$mysqlpass" -e "SELECT ID FROM \`temperature-$hostname\`;" > dbidnums.txt 2>/dev/null
        i=$(awk '/./{line=$0} END{print line}' dbidnums.txt)
        #Add one to make it acceptable
        ((i++))
        #printf "+ The new ID has been generated: ${green} $i ${nc}\n"
        echo "'$i', '$hostname', " >> qry1.txt
        tr -d "\n" < qry1.txt > qry2.txt
        sed -i 's/:       /\,      /g' coresrefined.csv
        sed -i 's/\,//g' coresrefined.csv
        input="coresrefined.csv"
        while IFS= read -r line
        do
          echo "$line" | awk '{print "'\''"$2"'\''" " ," }' >> qry2.txt
        done < "$input"
        tr -d "\n" < qry2.txt >> qry3.txt
        grep -Po '.*(?=,$)' qry3.txt >> qry4.txt
        echo ');" 2>/dev/null' >> qry4.txt
        echo "" >> qry4.txt
        echo ""
        tr -d "\n" < qry4.txt >> qry5.txt
        echo "" >> qry5.txt
        mv qry5.txt insertintodb.sh
        chmod 755 insertintodb.sh ; bash insertintodb.sh
        rm qry1.txt qry2.txt qry3.txt qry4.txt insertintodb.sh coresrefined.csv dbidnums.txt
        #mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status;SELECT * FROM \`temperature-$hostname\`;"
fi

exit
