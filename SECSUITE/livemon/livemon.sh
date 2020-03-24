#!/bin/bash
#le variables
#start=`date +%s`
basedir='/root/scripts/SECSUITE/livemon'
logfile='/var/log/auth.log'
weblogfile='/var/log/apache2/access.log'
readfileone='/root/scripts/SECSUITE/livemon/stepone.nlf'
readfiletwo='/root/scripts/SECSUITE/livemon/steptwo.nlf'
nlf='/root/scripts/SECSUITE/livemon/stepthree.nlf'
webips='/root/scripts/SECSUITE/livemon/web/web.log'
webfiltered='/root/scripts/SECSUITE/livemon/web/filtered.log'
#Enter MySQL Credentials
mysqluser="user"
mysqlpass="pass"
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
sort /root/scripts/SECSUITE/livemon/*.log* | uniq > /root/scripts/SECSUITE/livemon/uniqips.txt
#clear previous(ssh)
mysql --user=$mysqluser --password=$mysqlpass -e "USE livemon;truncate table iplist;" 2>/dev/null
mysql --user=$mysqluser --password=$mysqlpass -e "USE livemon;ALTER TABLE iplist AUTO_INCREMENT = 1;" 2>/dev/null
#load new dataset(ssh)
mysql --user=$mysqluser --password=$mysqlpass -e "USE livemon;LOAD DATA LOCAL INFILE '/root/scripts/SECSUITE/livemon/uniqips.txt' INTO TABLE iplist FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' (ipaddr);" 2>/dev/null
mysql --user=$mysqluser --password=$mysqlpass -e "USE livemon;select ipaddr INTO OUTFILE '/var/lib/mysql-files/final.txt' FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' FROM iplist;" 2>/dev/null
cp /var/lib/mysql-files/final.txt /root/scripts/SECSUITE/livemon/
echo ''
echo 'SSH Attackers Count: '
mysql --user=$mysqluser --password=$mysqlpass -e "USE livemon;select count(*) as Unique_Attackers from iplist;" 2>/dev/null
echo ''
rm final.txt
exit
