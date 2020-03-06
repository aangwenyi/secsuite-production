#!/bin/bash
#
#
#Begin
#
#Load in the variables;
whofile="whofile.txt"
importfile="/var/lib/mysql-files/importfile.csv"
#Edit the below MySQL credentials manually
user='username'
pass='password'
#
who > $whofile ; cat $whofile | awk '{print $1,",",$2,",",$3,","$4,",",$5}' > $importfile ; rm $whofile
#
#Truncate the table first
mysql --user=$user --password=$pass -e "USE status; truncate table loggedusers;"
#Load the new data
mysql --user=$user --password=$pass -e "USE status; LOAD DATA INFILE '/var/lib/mysql-files/importfile.csv' INTO TABLE loggedusers FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' (username,pts,date,time,ipaddr);" #2>/dev/null
#Load into Historical
mysql --user=$user --password=$pass -e "USE status; INSERT INTO hist_loggedusers SELECT *, CURRENT_TIMESTAMP(), RAND() FROM loggedusers;" 2>/dev/null
#Remove the source file
rm $importfile
