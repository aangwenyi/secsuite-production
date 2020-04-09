#!/bin/bash
#le variables
#start=`date +%s`
basedir='/root/scripts/SECSUITE/livemon'
dbf="$basedir/dbfile.txt"
dbf1="$basedir/dbfile1.txt"
logfile='/var/log/auth.log'
readfileone="$basedir/stepone.nlf"
readfiletwo="$basedir/steptwo.nlf"
nlf="$basedir/stepthree.nlf"
uniqips="$basedir/uniqips.csv"
#
#ASCII Colours
red='\033[0;31m'
green='\033[0;32m'
nc='\033[0m'
#
#Enter MySQL Credentials
mysqluser="user"
mysqlpass="pass"
#
printf "${green} ____  _____ ____ ____  _   _ ___ _____ _____${nc}\n"
printf "${green}/ ___|| ____/ ___/ ___|| | | |_ _|_   _| ____|${nc}\n"
printf "${green}\___ \|  _|| |   \___ \| | | || |  | | |  _|${nc}\n"
printf "${green} ___) | |__| |___ ___) | |_| || |  | | | |___${nc}\n"
printf "${green}|____/|_____\____|____/ \___/|___| |_| |_____|${nc}\n"
printf "${green}       	   	   LIVEMON${nc}\n"
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
#
mysql --user="$mysqluser" --password="$mysqlpass" -e "CREATE DATABASE IF NOT EXISTS livemon;" 2>/dev/null
#
mysqlshow --user=$mysqluser --password=$mysqlpass livemon >> $dbf 2>/dev/null
if grep -q "iplist" "$dbf"; then
        printf "${green} Table 'livemon.iplist' Exists, continuing...${nc}\n"
fi
#
if ! grep -q "iplist" "$dbf"; then
        printf "${red} Table 'livemon.iplist' Doesn't exist, installing...${nc}\n"
	mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status; CREATE TABLE IF NOT EXISTS iplist (id INT AUTO_INCREMENT NOT NULL, ipaddr VARCHAR(255) NOT NULL, PRIMARY KEY (id));" 2>/dev/null
	mysqlshow --user=$mysqluser --password=$mysqlpass livemon >> $dbf1 2>/dev/null
	if grep -q "iplist" "$dbf1"; then
	        printf "${green} Table 'livemon.iplist' Has been created, continuing...${nc}\n"
	fi
	rm $dbf1
fi
rm $dbf
#
#search logs
#predetermined check
cat $logfile | grep 'sshd' >> $readfileone
cat $logfile | grep 'Failed password for' >> $readfileone
#gather the attacker ips in case you need to forward them on
cat $readfileone | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' | awk '{print $0}' >> $readfiletwo
#create a unique list of addresses
sort $readfiletwo | uniq > $nlf
#Uncomment to keep logs:
cat $nlf > $basedir/production.log
rm $readfileone $readfiletwo $nlf
sort $basedir/*.log* | uniq > $uniqips
#clear previous(ssh)
mysql --user=$mysqluser --password=$mysqlpass -e "USE livemon;truncate table iplist;" 2>/dev/null
mysql --user=$mysqluser --password=$mysqlpass -e "USE livemon;ALTER TABLE iplist AUTO_INCREMENT = 1;" 2>/dev/null
#load new dataset(ssh)
mysql --user=$mysqluser --password=$mysqlpass -e "USE livemon;LOAD DATA LOCAL INFILE '$uniqips' INTO TABLE iplist FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' (ipaddr);" 2>/dev/null
echo ''
echo 'SSH Attackers Count: '
mysql --user=$mysqluser --password=$mysqlpass -e "USE livemon;select count(*) as Unique_Attackers from iplist;" 2>/dev/null
echo ''
exit
