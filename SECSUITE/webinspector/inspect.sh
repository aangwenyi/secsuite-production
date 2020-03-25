#!/bin/bash
#
#---------------------------------------------
#
#Les Variables:
basedir='/root/scripts/SECSUITE/webinspector'
importdir="/var/lib/mysql-files"
logfile='/var/log/apache2/access.log'
templogfile="$basedir/templog.log"
#
#Processing Files;
readfileone="$basedir/fileone.csv"
fileoneip="$basedir/fileoneip.csv"
procfileone="$basedir/fileoneproc.csv"
#
readfiletwo="$basedir/filetwo.csv"
filetwoip="$basedir/filetwoip.csv"
procfiletwo="$basedir/filetwoproc.csv"
#
readfilethree="$basedir/filethree.csv"
filethreeip="$basedir/filethreeip.csv"
procfilethree="$basedir/filethreeproc.csv"
#
#Import Files;
importfileone="$importdir/fileone.csv"
importfiletwo="$importdir/filetwo.csv"
importfilethree="$importdir/filethree.csv"
#
#MySQL Credentials
mysqluser="user"
mysqlpass="pass"
#
#DB Checks
dbc1="$basedir/dbcheck1.csv"
dbc2="$basedir/dbcheck2.csv"
#
#Get date for formatting
thisyear="$(date +'%Y')"
#
#ASCII Colours
red='\033[0;31m'
green='\033[0;32m'
nc='\033[0m'
#
#---------------------------------------------
#
cat $logfile >> $templogfile
#
#Database checks:
#
echo "Checking Database Configuration..."
mysql --user=$mysqluser --password=$mysqlpass -e "CREATE DATABASE IF NOT EXISTS webinspector;" 2>/dev/null
mysqlshow --user=$mysqluser --password=$mysqlpass webinspector >> $dbc1 2>/dev/null

if grep -q "inspection" "$dbc1"; then
        printf "${green}Table 'webinspector.inspection' exists, continuing...${nc}\n"
fi
if ! grep -q "inspection" "$dbc1"; then
        printf "${red}Table 'webinspector.inspection' Doesn't exist, Installing...${nc}\n"
        mysql --user=$mysqluser --password=$mysqlpass -e "USE webinspector;CREATE TABLE inspection (id INT AUTO_INCREMENT NOT NULL, ipaddr VARCHAR(255) NOT NULL, logdate VARCHAR(255) NOT NULL, pagerequested VARCHAR(255) NOT NULL, statuscode INT NOT NULL, PRIMARY KEY (id));" 2>/dev/null
        mysqlshow --user=$mysqluser --password=$mysqlpass webinspector >> $dbc2 2>/dev/null
	if grep -q "inspection" "$dbc2"; then
	printf "${green}Table 'webinspector.inspection' has been created, continuing...${nc}\n"
	fi
	rm $dbc2
fi
rm $dbc1
#
#Search logs:
#
#Predetermined check for status 200;
cat $templogfile | grep 'HTTP/1.1" 200' >> $readfileone
#Predetermined check for status 404;
cat $templogfile | grep 'HTTP/1.1" 404' >> $readfiletwo
#Predetermined check for index viewers;
cat $templogfile | grep 'index' >> $readfilethree
#
#Gather the ips into files:
cat $readfileone | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' | awk '{print $0}' >> $fileoneip
cat $readfiletwo | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' | awk '{print $0}' >> $filetwoip
cat $readfilethree | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' | awk '{print $0}' >> $filethreeip
#
#Process status 200
cat $readfileone | awk -F " " '{ print $1 "," $4 "," $7 "," $9}' >> $procfileone
#Format status 200
sed -i 's/\[//g' $procfileone
sed -i "s/$thisyear:/$thisyear /g" $procfileone
#
#Process status 404
cat $readfiletwo | awk -F " " '{ print $1 "," $4 "," $7 "," $9}' >> $procfiletwo
#Format status 404
sed -i 's/\[//g' $procfiletwo
sed -i "s/$thisyear:/$thisyear /g" $procfiletwo
#
#Process index viewers
cat $readfilethree | awk -F " " '{ print $1 "," $4 "," $7 "," $9}' >> $procfilethree
#Format status 404
sed -i 's/\[//g' $procfilethree
sed -i "s/$thisyear:/$thisyear /g" $procfilethree
#
#Le Debugging;
#-----------------------------------
#echo ""
#echo "Status 200:"
#wc -l $fileoneip
#echo ""
#echo "Status 200 Data Sample:"
#tail -5 $procfileone
#echo ""
#echo "Status 404:"
#wc -l $filetwoip
#echo ""
#echo "Status 404 Data Sample:"
#tail -5 $procfiletwo
#echo ""
#echo "Index Viewers:"
#wc -l $filethreeip
#echo ""
#echo "Index Viewers Data Sample:"
#tail -5 $procfilethree
#-----------------------------------
cat $procfileone >> $importfileone
cat $procfiletwo >> $importfiletwo
cat $procfilethree >> $importfilethree
while true; do
    read -p "Do you wish to keep previous entries? (Y/n): " yn
    case $yn in
        [Yy]* ) break ;;
        [Nn]* ) mysql --user="$mysqluser" --password="$mysqlpass" -e "USE webinspector;TRUNCATE TABLE inspection;" 2>/dev/null ; break ;;
        * ) echo "Please answer yes or no.";;
    esac
done

mysql --user="$mysqluser" --password="$mysqlpass" -e "USE webinspector;LOAD DATA INFILE '$importfileone' INTO TABLE inspection FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' (ipaddr, logdate, pagerequested, statuscode);" 2>/dev/null
mysql --user="$mysqluser" --password="$mysqlpass" -e "USE webinspector;LOAD DATA INFILE '$importfiletwo' INTO TABLE inspection FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' (ipaddr, logdate, pagerequested, statuscode);" 2>/dev/null
mysql --user="$mysqluser" --password="$mysqlpass" -e "USE webinspector;LOAD DATA INFILE '$importfilethree' INTO TABLE inspection FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' (ipaddr, logdate, pagerequested, statuscode);" 2>/dev/null

#Delete bulky files:
rm $readfileone $procfileone $readfiletwo $procfiletwo $readfilethree $procfilethree $fileoneip $filetwoip $filethreeip $templogfile $importfileone $importfiletwo $importfilethree

exit