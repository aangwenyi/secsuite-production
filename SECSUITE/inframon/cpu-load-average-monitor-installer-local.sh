#!/bin/bash
#
# ____  _____ ____ ____  _   _ ___ _____ _____
#/ ___|| ____/ ___/ ___|| | | |_ _|_   _| ____|
#\___ \|  _|| |   \___ \| | | || |  | | |  _|
# ___) | |__| |___ ___) | |_| || |  | | | |___
#|____/|_____\____|____/ \___/|___| |_| |_____|
#       CPU-LOAD-AVERAGE-INSTALLER
#
#
#Global Variables
#
#MySQL Creds
mysqluser="user"
mysqlpass="pass"
#
#ASCII Colours
red='\033[0;31m'
green='\033[0;32m'
nc='\033[0m'
#
basedir="/root/scripts/SECSUITE/inframon"
qry1="$basedir/qry1.txt"
qry2="$basedir/qry2.txt"
#
#Begin
#
printf "${green} ____  _____ ____ ____  _   _ ___ _____ _____${nc}\n"
printf "${green}/ ___|| ____/ ___/ ___|| | | |_ _|_   _| ____|${nc}\n"
printf "${green}\___ \|  _|| |   \___ \| | | || |  | | |  _|${nc}\n"
printf "${green} ___) | |__| |___ ___) | |_| || |  | | | |___${nc}\n"
printf "${green}|____/|_____\____|____/ \___/|___| |_| |_____|${nc}\n"
printf "${green}       CPU-LOAD-AVERAGE-INSTALLER${nc}\n"

echo ''
echo "Welcome to the SECSUITE CPU Load Avg Installer"
echo ''

echo "Checking for previous installs..."
inframon2="$basedir/cpufiles/"
if [ -d "$inframon2" ]; then
  printf "${green}${inframon2} ${nc} Exists, continuing...\n"
else
  printf "+ ${red}${inframon2} ${nc} Not Found. Creating new workspace...\n"
  mkdir $basedir/cpufiles/
fi
echo ''
while true; do
    read -p "Have you already configured your CPU Load Database Credentials? (y/n): " yn
    case $yn in
        [Yy]* ) echo "Skipping this step."; break;;
        [Nn]* ) echo ""
                read -p "Please enter the MySQL User: " manmysqluser
                read -s -p "Password: " manmysqlpass
                break;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo ''
read -p "Please enter the HOSTNAME of the asset you wish to add: " hostname
echo ''
echo "Checking for active host installs..."
FILE="$basedir/cpufiles/$hostname/cpu-load-monitor.sh"
                if [ -f "$FILE" ]; then
                    printf "+ ${red}$hostname ${nc} Already Exists. Exiting.\n" ; exit
                else
                    printf "+ ${green}$hostname ${nc} Not existing, it will be created...\n"
                        echo "Do you wish to name this host $hostname? (y/n): "
                        select yn in "Yes" "No"; do
                            case $yn in
                                Yes ) mkdir $basedir/cpufiles/$hostname ; break;;
                                No ) read -p "Please enter the identifying NAME of the asset you wish to add: " hostname ; break;;
                            esac
                done
                fi
echo ''
#
#Begin Constructing Package;
#
cpumonitor="$basedir/cpufiles/$hostname/cpu-load-monitor.sh"
FILE="$basedir/cpufiles/$hostname/cpu-load-monitor.sh"
if [ -f "$FILE" ]; then
    printf "+ ${red}$hostname ${nc} Already Exists. Exiting. \n" ; exit
else
    printf "+ ${green}$hostname ${nc} will be created...\n"
    touch $cpumonitor
        echo "#!/bin/bash" >> $cpumonitor
        echo "#" >> $cpumonitor
        echo "#Variables" >> $cpumonitor
        echo "#" >> $cpumonitor
        echo "#MySQL Creds" >> $cpumonitor
        echo "mysqluser='$manmysqluser'" >> $cpumonitor
        echo "mysqlpass='$manmysqlpass'" >> $cpumonitor
        echo "#" >> $cpumonitor
        echo "hostnamefile='$basedir/cpufiles/$hostname/workfile.csv'" >> $cpumonitor
        echo "hostname=$hostname" >> $cpumonitor
        echo "importfile='/var/lib/mysql-files/cpuimport.csv'" >> $cpumonitor
        echo "tr -d '\n' < $ hostnamefile > $ importfile" >> $cpumonitor
        echo "echo ' ' >> $ importfile" >> $cpumonitor
        echo "mysql --user=$ mysqluser --password=$ mysqlpass -e " >> $qry1
        echo '"USE status; truncate table cpu;" 2>/dev/null ' >> $qry1
        tr -d '\n' < $qry1 > $qry2
        cat $qry2 >> $cpumonitor
        rm $qry1 $qry2
        echo "" >> $cpumonitor
        echo "mysql --user=$ mysqluser --password=$ mysqlpass -e " >> $qry1
        echo '"' >> $qry1
        echo "USE status;LOAD DATA INFILE '/var/lib/mysql-files/cpuimport.csv' INTO TABLE cpu FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';" >> $qry1
        echo '"' >> $qry1
        echo " 2>/dev/null" >> $qry1
        tr -d '\n' < $qry1 > $qry2
        cat $qry2 >> $cpumonitor
        rm $qry1 $qry2
        echo "" >> $cpumonitor
        echo 'mysql --user=$ mysqluser --password=$ mysqlpass -e "use status;INSERT INTO hist_cpu SELECT *, CURRENT_TIMESTAMP() FROM cpu;" 2>/dev/null' >> $cpumonitor
        echo "rm $ hostnamefile $ importfile" >> $cpumonitor
        echo "exit" >> $cpumonitor
fi
#Process the monitor
        sed -i 's/$ mysqluser/$mysqluser/g' $cpumonitor
        sed -i 's/$ mysqlpass/$mysqlpass/g' $cpumonitor
        sed -i 's/$ importfile/$importfile/g' $cpumonitor
        sed -i 's/$ hostname/$hostname/g' $cpumonitor
        sed -i 's/$ hostname.csv/$hostname.csv/g' $cpumonitor
        sed -i 's/$ hostnamefile/$hostnamefile/g' $cpumonitor
bash $basedir/cpu-load-new-node-installer-local.sh
exit
