#!/bin/bash
#
basedir="/root/scripts/SECSUITE/inframon"
dbf="$basedir/dbf.txt"
dbf1="$basedir/dbf1.txt"
qry1="$basedir/qry1.txt"
qry2="$basedir/qry2.txt"
#
#ASCII Colours
red='\033[0;31m'
green='\033[0;32m'
nc='\033[0m'
#
printf "${green} ____  _____ ____ ____  _   _ ___ _____ _____${nc}\n"
printf "${green}/ ___|| ____/ ___/ ___|| | | |_ _|_   _| ____|${nc}\n"
printf "${green}\___ \|  _|| |   \___ \| | | || |  | | |  _|${nc}\n"
printf "${green} ___) | |__| |___ ___) | |_| || |  | | | |___${nc}\n"
printf "${green}|____/|_____\____|____/ \___/|___| |_| |_____|${nc}\n"
printf "${green}         BANDWIDTH-MONITOR-INSTALLER${nc}\n"
#
echo ''
while true; do
    read -p "Have you already configured your Database Credentials? (y/n): " yn
    case $yn in
        [Yy]* ) echo "Skipping this step." ; echo '' ; break;;
        [Nn]* ) echo ""
                read -p "Please enter the MySQL User: " mysqluser
                read -s -p "$mysqluser's Password: " mysqlpass ; echo ""
                break;;
        * ) echo "Please answer yes or no.";;
    esac
done
#Database Config;
mysqlshow --user=$mysqluser --password=$mysqlpass status >> $dbf 2>/dev/null
if grep -q "bandwidthstatus" "$dbf"; then
        printf "${green} Table 'status.bandwidthstatus' Exists, continuing...${nc}\n"
fi
#
if ! grep -q "bandwidthstatus" "$dbf"; then
        printf "${red} Table 'status.bandwidthstatus' Doesn't exist, installing...${nc}\n"
	mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status; CREATE TABLE IF NOT EXISTS bandwidthstatus (id INT AUTO_INCREMENT NOT NULL, hostname VARCHAR(255), type VARCHAR(255), bytes VARCHAR(255), humanformat VARCHAR(255), PRIMARY KEY (id));" 2>/dev/null
	mysqlshow --user=$mysqluser --password=$mysqlpass status >> $dbf1 2>/dev/null
	if grep -q "bandwidthstatus" "$dbf1"; then
	        printf "${green} Table 'status.bandwidthstatus' Has been created, continuing...${nc}\n"
	fi
	rm $dbf1
fi
rm $dbf
#
mysqlshow --user=$mysqluser --password=$mysqlpass status >> $dbf 2>/dev/null
if grep -q "hist_bandwidthstatus" "$dbf"; then
        printf "${green} Table 'status.hist_bandwidthstatus' Exists, continuing...${nc}\n"
fi
#
if ! grep -q "hist_bandwidthstatus" "$dbf"; then
        printf "${red} Table 'status.hist_bandwidthstatus' Doesn't exist, installing...${nc}\n"
	mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status; CREATE TABLE IF NOT EXISTS hist_bandwidthstatus (id INT AUTO_INCREMENT NOT NULL, hostname VARCHAR(255), type VARCHAR(255), bytes VARCHAR(255), humanformat VARCHAR(255), timestamp VARCHAR(255) NOT NULL, PRIMARY KEY (id));" 2>/dev/null
	mysqlshow --user=$mysqluser --password=$mysqlpass status >> $dbf1 2>/dev/null
	if grep -q "hist_bandwidthstatus" "$dbf1"; then
	        printf "${green} Table 'status.hist_bandwidthstatus' Has been created, continuing...${nc}\n"
	fi
	rm $dbf1
fi
rm $dbf
#
read -p "Please enter a hostname for this machine: " hostname
script="$basedir/bandwidth/bandwidth-monitor-local-$hostname.sh"
#
file="$script"
if test -f "$file"; then
    echo "$file exists. Exiting."
    exit
fi
#
echo ''
echo "+ Your current interfaces: "
ip link show
echo ''
read -p "+ Please input an interface to monitor: " interface
echo ''
echo "Building Script..."
echo ''
echo "#!/bin/bash" >> $script
echo "#" >> $script
echo "interface='$interface'" >> $script
echo "mysqluser='$mysqluser'" >> $script
echo "mysqlpass='$mysqlpass'" >> $script
echo "hostname='$hostname'" >> $script
echo "#" >> $script
echo "basedir='/root/scripts/SECSUITE/inframon/bandwidth'" >> $script
echo 'rawfile="$basedir/rawfile.txt"' >> $script
echo 'nclines="$basedir/nclines.txt"' >> $script
echo 'procbw="$basedir/procbw.txt"' >> $script
echo 'txfile="$basedir/txfile.txt"' >> $script
echo 'rxfile="$basedir/rxfile.txt"' >> $script
echo 'txout="$basedir/txout.txt"' >> $script
echo 'rxout="$basedir/rxout.txt"' >> $script
echo 'importfile="/var/lib/mysql-files/importfile.txt"' >> $script
echo "#" >> $script
echo ''
echo '/sbin/ifconfig > $rawfile' >> $script
echo '#' >> $script
echo '#Get Interface' >> $script
echo 'cat $rawfile | grep -A 9 "$interface" >> $nclines' >> $script
echo '#Print Section (Debug)' >> $script
echo '#cat $nclines | awk "{print $1}"' >> $script
echo '#Get RX & TX Values' >> $script
echo '#echo "Bandwidth Usage for interface $interface: "' >> $script
echo 'cat $nclines | grep -E "bytes" > $procbw' >> $script
echo '#File Processing' >> $script
echo 'cat $procbw | awk -v FS="(RX|\))" ' >> $qry1
echo "'{print $ 2}' > $ rxfile" >> $qry1
sed -i 's/$ 2/$2/g' $qry1
sed -i 's/$ rxfile/$rxfile/g' $qry1
tr -d "\n" < $qry1 > $qry2
echo "" >> $qry2
cat $qry2 >> $script
rm $qry1 $qry2
echo 'cat $procbw | awk -v FS="(TX|\))" ' >> $qry1
echo "'{print $ 3}' > $ txfile" >> $qry1
sed -i 's/$ 3/$3/g' $qry1
sed -i 's/$ txfile/$txfile/g' $qry1
tr -d "\n" < $qry1 > $qry2
echo "" >> $qry2
cat $qry2 >> $script
rm $qry1 $qry2
echo 'cat $rxfile | tr -d "(" > $rxout' >> $script
echo 'cat $txfile | tr -d "(" > $txout' >> $script
echo 'sed -i "1s/^.//" $rxout' >> $script
echo 'sed -i "1s/^.//" $txout' >> $script
echo 'sed -i "s/ / \, /g" $rxout' >> $script
echo 'sed -i "s/ / \, /g" $txout' >> $script
echo 'sed -i "s/ \, KB/ KB/g" $rxout' >> $script
echo 'sed -i "s/ \, KB/ KB/g" $txout' >> $script
echo 'sed -i "s/ \, MB/ MB/g" $rxout' >> $script
echo 'sed -i "s/ \, MB/ MB/g" $txout' >> $script
echo 'sed -i "s/ \, GB/ GB/g" $rxout' >> $script
echo 'sed -i "s/ \, GB/ GB/g" $txout' >> $script
echo 'sed -i "s/bytes://g" $rxout' >> $script
echo 'sed -i "s/bytes://g" $txout' >> $script
echo 'sed -i "s/ //g" $rxout' >> $script
echo 'sed -i "s/ //g" $txout' >> $script
echo 'echo "$hostname,RX,$(cat $rxout)" >> $importfile' >> $script
echo 'echo "$hostname,TX,$(cat $txout)" >> $importfile' >> $script
echo 'mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status;INSERT INTO hist_bandwidthstatus (hostname, type, bytes, humanformat, timestamp) SELECT hostname, type, bytes, humanformat, CURRENT_TIMESTAMP() FROM bandwidthstatus;" 2>/dev/null' >> $script
echo 'mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status;truncate table bandwidthstatus;" 2>/dev/null' >> $script
echo 'mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status;' >> $qry1
echo "LOAD DATA INFILE '$ importfile' INTO TABLE bandwidthstatus FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' (hostname, type, bytes, humanformat);" >> $qry1
echo '"' >> $qry1
sed -i 's/$ importfile/$importfile/g' $qry1
tr -d "\n" < $qry1 > $qry2
echo " 2>/dev/null" >> $qry2
cat $qry2 >> $script
rm $qry1 $qry2
#
echo 'rm $rawfile $nclines $procbw $rxfile $txfile $rxout $txout $importfile' >> $script
#
echo ''
echo "Script Output: "
bash $script
mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status; SELECT * FROM bandwidthstatus;" 2>/dev/null
