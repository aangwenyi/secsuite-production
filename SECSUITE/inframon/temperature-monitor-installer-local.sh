#!/bin/bash
#ASCII Colours
red='\033[0;31m'
green='\033[0;32m'
nc='\033[0m'
#
#Begin
#
printf "${green} ____  _____ ____ ____  _   _ ___ _____ _____${nc}\n"
printf "${green}/ ___|| ____/ ___/ ___|| | | |_ _|_   _| ____|${nc}\n"
printf "${green}\___ \|  _|| |   \___ \| | | || |  | | |  _|${nc}\n"
printf "${green} ___) | |__| |___ ___) | |_| || |  | | | |___${nc}\n"
printf "${green}|____/|_____\____|____/ \___/|___| |_| |_____|${nc}\n"
printf "${green}       TEMPERATURE-MONITOR-INSTALLER${nc}\n"
#
echo ''
echo "Welcome to the SECSUITE Temperature Monitor Installer"
echo ''
#
read -p "Please enter the HOSTNAME of your new asset: " hostname
#
while true; do
    read -p "Have you already configured your Database Credentials? (y/n): " yn
    case $yn in
        [Yy]* ) echo "Skipping this step."; break;;
        [Nn]* ) echo ""
                read -p "Please enter the MySQL User: " mysqluser
                read -s -p "Password: " mysqlpass ; echo ""
                break;;
        * ) echo "Please answer yes or no.";;
    esac
done
#
#Begin Construction
#
sed -i "s/mysqluser='user'/mysqluser='$mysqluser'/g" /root/scripts/SECSUITE/inframon/temperaturefiles/temperature-monitor-local.sh
sed -i "s/mysqlpass='pass'/mysqlpass='$mysqlpass'/g" /root/scripts/SECSUITE/inframon/temperaturefiles/temperature-monitor-local.sh
sed -i "s/hostname='host'/hostname='$hostname'/g" /root/scripts/SECSUITE/inframon/temperaturefiles/temperature-monitor-local.sh
echo "Setup Complete. Executing..."
bash /root/scripts/SECSUITE/inframon/temperaturefiles/temperature-monitor-local.sh
bash /root/scripts/SECSUITE/inframon/temperaturefiles/temperature-monitor-local.sh
mysql --user="$mysqluser" --password="$mysqlpass" -e "use status;select * from \`temperature-$hostname\`;" 2>/dev/null
mysql --user="$mysqluser" --password="$mysqlpass" -e "use status;select * from \`hist-temperature-$hostname\`;" 2>/dev/null
exit
