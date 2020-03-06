#!/bin/bash
user='username'
pass='password'

echo ""
echo "Displaying actively monitored Apache hosts: "
mysql --user=$user --password=$pass -e "use status;select * from apachestatus;" 2>/dev/null

echo ""
echo "Displaying historical monitored Apache hosts: "
mysql --user=$user --password=$pass -e "use status;select * from hist_apachestatus order by importtime desc limit 1;" 2>/dev/null

echo ""
echo "Displaying actively monitored cpu load averages: "
mysql --user=$user --password=$pass -e "use status;select * from cpu;" 2>/dev/null

echo ""
echo "Displaying historical monitored cpu load averages: "
mysql --user=$user --password=$pass -e "use status;select * from hist_cpu order by importtime desc limit 1;" 2>/dev/null

echo ""
echo "Displaying actively monitored cpu temperatures: "
mysql --user=$user --password=$pass -e "use status;select * from temperature;" 2>/dev/null

echo ""
echo "Displaying historical monitored cpu temperatures: "
mysql --user=$user --password=$pass -e "use status;select * from hist_temperature order by importtime desc limit 1;" 2>/dev/null

echo ""
echo "Displaying actively monitored latency: "
mysql --user=$user --password=$pass -e "use status;select * from srv;" 2>/dev/null

echo ""
echo "Displaying historical monitored latency: "
mysql --user=$user --password=$pass -e "use status;select * from hist_srv order by importtime desc limit 1;" 2>/dev/null

echo ""
echo "Displaying actively monitored connected users: "
mysql --user=$user --password=$pass -e "use status;select * from loggedusers;" 2>/dev/null

echo ""
echo "Displaying actively monitored connected users: "
mysql --user=$user --password=$pass -e "use status;select * from hist_loggedusers order by importtime desc;" 2>/dev/null
