#!/bin/bash
#
read -p "Please enter the IP address of the remote node: " ipaddr
echo ''
read -p "Please enter a Remote Administrative MySQL user: " mysqluser
echo ''
read -s -p "Please enter $mysqluser's password: " mysqlpass
echo ''
mysql -h"$ipaddr" -D'status' --user="$mysqluser" --password="$mysqlpass" -e "SELECT * FROM apachestatus;" 2>/dev/null
echo ''
mysql -h"$ipaddr" -D'status' --user="$mysqluser" --password="$mysqlpass" -e "SELECT * FROM cpu;" 2>/dev/null
echo ''
mysql -h"$ipaddr" -D'status' --user="$mysqluser" --password="$mysqlpass" -e "SELECT * FROM srv;" 2>/dev/null
echo ''
mysql -h"$ipaddr" -D'status' --user="$mysqluser" --password="$mysqlpass" -e "SELECT * FROM temperature;" 2>/dev/null
echo ''
mysql -h"$ipaddr" -D'status' --user="$mysqluser" --password="$mysqlpass" -e "SELECT * FROM loggedusers;" 2>/dev/null
echo ''
