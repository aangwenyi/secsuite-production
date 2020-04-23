#!/bin/bash
#
basedir="/root/scripts/SECSUITE/inframon"
dbf="$basedir/dbfile.txt"
dbf1="$basedir/dbfile1.txt"
ramfile="$basedir/ramfile.txt"
procfile="$basedir/processfile.txt"
qry1="$basedir/qry1.txt"
qry2="$basedir/qry2.txt"
script="$basedir/memory/memory-monitor-local-probe.sh"
#
#ASCII Colours
red='\033[0;31m'
green='\033[0;32m'
nc='\033[0m'
#
#MySQL Creds (optional)
mysqluser="user"
mysqlpass="pass"
#
printf "${green} ____  _____ ____ ____  _   _ ___ _____ _____${nc}\n"
printf "${green}/ ___|| ____/ ___/ ___|| | | |_ _|_   _| ____|${nc}\n"
printf "${green}\___ \|  _|| |   \___ \| | | || |  | | |  _|${nc}\n"
printf "${green} ___) | |__| |___ ___) | |_| || |  | | | |___${nc}\n"
printf "${green}|____/|_____\____|____/ \___/|___| |_| |_____|${nc}\n"
printf "${green}       	   MEMORY-STATUS-INSTALLER${nc}\n"
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
#
	
mysqlshow --user=$mysqluser --password=$mysqlpass status >> $dbf 2>/dev/null
if grep -q "memorystatus" "$dbf"; then
        printf "${green} Table 'status.memorystatus' Exists, continuing...${nc}\n"
fi
#
if ! grep -q "memorystatus" "$dbf"; then
        printf "${red} Table 'status.memorystatus' Doesn't exist, installing...${nc}\n"
	mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status; CREATE TABLE IF NOT EXISTS memorystatus (id INT AUTO_INCREMENT NOT NULL, hostname VARCHAR(255), type VARCHAR(255), totalmemory VARCHAR(255), usedmemory VARCHAR(255), freememory VARCHAR(255), sharedmemory VARCHAR(255), cachedmemory VARCHAR(255), availablememory VARCHAR(255), PRIMARY KEY (id));" 2>/dev/null
	mysqlshow --user=$mysqluser --password=$mysqlpass status >> $dbf1 2>/dev/null
	if grep -q "memorystatus" "$dbf1"; then
	        printf "${green} Table 'status.memorystatus' Has been created, continuing...${nc}\n"
	fi
	rm $dbf1
fi
rm $dbf

mysqlshow --user=$mysqluser --password=$mysqlpass status >> $dbf 2>/dev/null
if grep -q "hist_memorystatus" "$dbf"; then
        printf "${green} Table 'status.hist_memorystatus' Exists, continuing...${nc}\n"
fi
#
if ! grep -q "hist_memorystatus" "$dbf"; then
        printf "${red} Table 'status.hist_memorystatus' Doesn't exist, installing...${nc}\n"
	mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status; CREATE TABLE IF NOT EXISTS hist_memorystatus (id INT AUTO_INCREMENT NOT NULL, hostname VARCHAR(255), type VARCHAR(255), totalmemory VARCHAR(255), usedmemory VARCHAR(255), freememory VARCHAR(255), sharedmemory VARCHAR(255), cachedmemory VARCHAR(255), availablememory VARCHAR(255), timestamp VARCHAR(255) NOT NULL, PRIMARY KEY (id));" 2>/dev/null
	mysqlshow --user=$mysqluser --password=$mysqlpass status >> $dbf1 2>/dev/null
	if grep -q "hist_memorystatus" "$dbf1"; then
	        printf "${green} Table 'status.hist_memorystatus' Has been created, continuing...${nc}\n"
	fi
	rm $dbf1
fi
rm $dbf

	
#
read -p "Please enter a hostname for this machine: " hostname
#
echo ''
echo "Creating your script..."
echo ''
echo "#!/bin/bash" >> $script
echo "hostname='$hostname'" >> $script
echo "basedir='/root/scripts/SECSUITE/inframon/memory'" >> $script
echo 'procfile="$basedir/procfile.txt"' >> $script
echo 'ramfile="$basedir/ramfile.txt"' >> $script
echo 'importfile="/var/lib/mysql-files/importfilememorystatus.csv"' >> $script
echo "#" >> $script
echo "mysqluser='$mysqluser'" >> $script
echo "mysqlpass='$mysqlpass'" >> $script
echo "#" >> $script
echo 'free -m -h > $ramfile' >> $script
echo "#" >> $script
#
echo "sed -i 's/        /	/g' $ ramfile" >> $script
echo "sed -i 's/Mem:/\, Mem/g' $ ramfile" >> $script
echo "sed -i 's/Swap:/\, Swap/g' $ ramfile" >> $script
#
echo "tail -n +2 $ ramfile > $ procfile" >> $script
echo "sed -i 's/^/$hostname/' $ procfile" >> $script
#
echo "cat $ procfile | awk '{print " >> $qry1
echo '$1 " " $2 " , " $3 " , " $4 " , " $5 " , " $6 " , " $7 " , " $8}' >> $qry1
echo "' > $ importfile" >> $qry1
tr -d '\n' < $qry1 > $qry2
echo "" >> $qry2
cat $qry2 >> $script
echo "#" >> $script
rm $qry1 $qry2
# echo "cat $ importfile" >> $script
echo 'mysql --user="$ mysqluser" --password="$ mysqlpass" -e "USE status;TRUNCATE TABLE memorystatus;" 2>/dev/null' >> $script
echo 'mysql --user="$ mysqluser" --password="$ mysqlpass" -e "USE status;LOAD DATA INFILE ' >> $qry1
echo "'$ importfile' INTO TABLE memorystatus FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' (hostname, type, totalmemory, usedmemory, freememory, sharedmemory, cachedmemory, availablememory);" >> $qry1
echo '" 2>/dev/null' >> $qry1
tr -d '\n' < $qry1 > $qry2
echo "" >> $qry2
cat $qry2 >> $script
rm $qry1 $qry2
echo 'mysql --user="$ mysqluser" --password="$ mysqlpass" -e "USE status;INSERT INTO hist_memorystatus (hostname, type, totalmemory, usedmemory, freememory, sharedmemory, cachedmemory, availablememory, timestamp) SELECT hostname, type, totalmemory, usedmemory, freememory, sharedmemory, cachedmemory, availablememory, CURRENT_TIMESTAMP() FROM memorystatus;" 2>/dev/null' >> $script
echo "" >> $script
echo "rm $ ramfile $ procfile $ importfile" >> $script
sed -i 's/$ ramfile/$ramfile/g' $script
sed -i 's/$ procfile/$procfile/g' $script
sed -i 's/$ importfile/$importfile/g' $script
sed -i 's/$ mysqluser/$mysqluser/g' $script
sed -i 's/$ mysqlpass/$mysqlpass/g' $script
#
echo "SQL Imported Data:"
mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status; SELECT * FROM memorystatus;" 2>/dev/null
