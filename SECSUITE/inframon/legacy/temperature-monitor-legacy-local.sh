#!/bin/bash
#
# ____  _____ ____ ____  _   _ ___ _____ _____
#/ ___|| ____/ ___/ ___|| | | |_ _|_   _| ____|
#\___ \|  _|| |   \___ \| | | || |  | | |  _|
# ___) | |__| |___ ___) | |_| || |  | | | |___
#|____/|_____\____|____/ \___/|___| |_| |_____|
#       CPU-TEMPERATURE-INSTALLER
#
#
#Global Variables
#
#MySQL Creds (optional)
#mysqluser="user"
#mysqlpass="pass"
#
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
printf "${green}       CPU-TEMPERATURE-INSTALLER${nc}\n"
#
echo ''
echo "Welcome to the SECSUITE CPU Temperature Monitor Installer"
echo ''
#
read -p "Please enter the HOSTNAME of your new asset: " hostname


while true; do
    read -p "Have you already configured your CPU Temperature Database Credentials? (y/n): " yn
    case $yn in
        [Yy]* ) echo "Skipping this step."; break;;
        [Nn]* ) echo ""
                read -p "Please enter the MySQL User: " mysqluser
                read -s -p "Password: " mysqlpass ; echo ""
                break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "Checking for previous installs..."
echo ''
monitor="/root/scripts/SECSUITE/inframon/temperaturefiles/$hostname-temp-monitor.sh"
if [ -f "$monitor" ]; then
printf "+ ${red} $hostname Already Exists! Derp. \n"
fi
#
#Begin Construction
#
constructfile="/root/scripts/SECSUITE/inframon/temperaturefiles/$hostname-temp-monitor.sh"
touch "/root/scripts/SECSUITE/inframon/temperaturefiles/$hostname-temp-monitor.sh"
echo "#!/bin/bash" >> $constructfile
echo "mysqluser='$mysqluser'" >> $constructfile
echo "mysqlpass='$mysqlpass'" >> $constructfile
echo "#" >> $constructfile
echo "#Get the Temps" >> $constructfile
echo "sensors >> temptemp.txt" >> $constructfile
echo "#Get only the temp values" >> $constructfile
echo 'cat temptemp.txt | grep -E "Core" >> tempcores.csv' >> $constructfile
echo "#Refine" >> $constructfile
echo "sed -i 's/,/ /g' tempcores.csv" >> $constructfile
echo "sed -r 's/.{32}$//' tempcores.csv > coresrefined.csv" >> $constructfile
echo "sed -i '1 i\1,$hostname,' coresrefined.csv" >> $constructfile
echo "tr -d '\n' < coresrefined.csv > importfile.csv" >> $constructfile
echo "cat importfile.csv > /var/lib/mysql-files/corestempimport.csv" >> $constructfile
echo "sed -i 's/(//g' /var/lib/mysql-files/corestempimport.csv" >> $constructfile
echo "sed -i 's/)//g' /var/lib/mysql-files/corestempimport.csv" >> $constructfile
echo "sed -i 's/+//g' /var/lib/mysql-files/corestempimport.csv" >> $constructfile
echo "sed -i 's/°C//g' /var/lib/mysql-files/corestempimport.csv" >> $constructfile
echo "sed -i 's/Core/\| Core/g' /var/lib/mysql-files/corestempimport.csv" >> $constructfile
echo 'mysql --user=$ mysqluser --password=$ mysqlpass -e "USE status;truncate table temperature;" 2>/dev/null ' >> $constructfile
echo "mysql --user=$ mysqluser --password=$ mysqlpass -e " >> buildtemp.txt
echo '"USE status;LOAD DATA INFILE ' >> buildtemp.txt
echo "'/var/lib/mysql-files/corestempimport.csv' "  >> buildtemp.txt
echo "INTO TABLE temperature FIELDS TERMINATED BY " >> buildtemp.txt
echo "','" >> buildtemp.txt
echo "LINES TERMINATED BY " >> buildtemp.txt
echo "'\n';" >> buildtemp.txt
echo '"' >> buildtemp.txt
echo " 2>/dev/null ; " >> buildtemp.txt
tr -d '\n' < buildtemp.txt >> $constructfile
rm buildtemp.txt
echo 'mysql --user=$ mysqluser --password=$ mysqlpass -e "use status;INSERT INTO hist_temperature SELECT *, CURRENT_TIMESTAMP(), RAND() FROM temperature;" 2>/dev/null' >> $constructfile
echo "#Remove build files" >> $constructfile
echo "rm temptemp.txt tempcores.csv coresrefined.csv importfile.csv /var/lib/mysql-files/corestempimport.csv" >> $constructfile
echo "#" >> $constructfile
echo "#'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'" >> $constructfile
echo "#" >> $constructfile
echo "" >> $constructfile
sed -i 's/$ mysqluser/$mysqluser/g' $constructfile
sed -i 's/$ mysqlpass/$mysqlpass/g' $constructfile
outputfile=$constructfile
if bash -f "$outputfile"; then
    printf "+ Your CPU Temperature monitor has been generated: ${green}$outputfile${nc}\n"
fi
exit
