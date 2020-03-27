#!/bin/bash
#
# ____  _____ ____ ____  _   _ ___ _____ _____
#/ ___|| ____/ ___/ ___|| | | |_ _|_   _| ____|
#\___ \|  _|| |   \___ \| | | || |  | | |  _|
# ___) | |__| |___ ___) | |_| || |  | | | |___
#|____/|_____\____|____/ \___/|___| |_| |_____|
#       CPU-LOAD-AVERAGE-MONITOR
#
#
#Global Variables
#
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
dbf="$basedir/dbfile.txt"
dbf1="$basedir/dbfile1.txt"
dbid="$basedir/dbidnums.txt"
lid="$basedir/lastid.txt"
sclid="$basedir/sclastid.txt"
#
#Begin
#
printf "${green} ____  _____ ____ ____  _   _ ___ _____ _____${nc}\n"
printf "${green}/ ___|| ____/ ___/ ___|| | | |_ _|_   _| ____|${nc}\n"
printf "${green}\___ \|  _|| |   \___ \| | | || |  | | |  _|${nc}\n"
printf "${green} ___) | |__| |___ ___) | |_| || |  | | | |___${nc}\n"
printf "${green}|____/|_____\____|____/ \___/|___| |_| |_____|${nc}\n"
printf "${green}       CPU-LOAD-AVERAGE-MONITOR${nc}\n"
echo ''
echo "Welcome to the SECSUITE CPU Load Avg monitor installer"
echo ''
while true; do
    read -p "Have you already configured your CPU Load Database Credentials? (y/n): " yn
    case $yn in
        [Yy]* ) echo "Skipping this step."; break;;
        [Nn]* ) echo ""
                read -p "Please enter the MySQL User: " mysqluser
                read -s -p "Password: " mysqlpass
                break;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo ''
echo "Checking Database Configuration..."
mysqlshow --user=$mysqluser --password=$mysqlpass status >> $dbf 2>/dev/null
if grep -q "cpu" "$dbf"; then
        printf "${green}Table 'status.cpu' exists, continuing...${nc}\n"
fi
if ! grep -q "cpu" "$dbf"; then
        printf "${red}Table 'status.cpu' Doesn't exist, Installing...${nc}\n"
        mysql --user=$mysqluser --password=$mysqlpass -e "USE status;CREATE TABLE IF NOT EXISTS cpu ( id INT AUTO_INCREMENT NOT NULL, hostname VARCHAR(255), loadonemin VARCHAR(10), loadtenmin VARCHAR(10), loadfifmin VARCHAR(10), x VARCHAR(10), y VARCHAR(10), PRIMARY KEY (id));" 2>/dev/null
	mysqlshow --user=$mysqluser --password=$mysqlpass status >> $dbf1 2>/dev/null
	if grep -q "cpu" "$dbf1"; then
	printf "${green}Table 'status.cpu' has been created, continuing..."
	fi
fi
rm $dbf $dbf1

echo "Checking Historical Database Configuration..."
mysqlshow --user=$mysqluser --password=$mysqlpass status >> $dbf 2>/dev/null
if grep -q "hist_cpu" "$dbf"; then
        printf "${green}Table 'status.hist_cpu' exists, continuing...${nc}\n"
fi
if ! grep -q "hist_cpu" "$dbf"; then
        printf "${red}Table 'status.hist_cpu' Doesn't exist, Installing...${nc}\n"
        mysql --user=$mysqluser --password=$mysqlpass -e "USE status;CREATE TABLE IF NOT EXISTS hist_cpu ( id INT NOT NULL, hostname VARCHAR(255), loadonemin VARCHAR(10), loadtenmin VARCHAR(10), loadfifmin VARCHAR(10), x VARCHAR(10), y VARCHAR(10), timestamp VARCHAR(255) NOT NULL, PRIMARY KEY (timestamp));" 2>/dev/null
	mysqlshow --user=$mysqluser --password=$mysqlpass status >> $dbf1 2>/dev/null
	if grep -q "hist_cpu" "$dbf1"; then
	printf "${green}Table 'status.hist_cpu' has been created, continuing...${nc}\n"
	fi
fi
rm $dbf $dbf1
#
#Get Current Amount of Configured Assets
mysql --user=$mysqluser --password=$mysqlpass -e "use status;SELECT ID FROM cpu;" > $dbid 2>/dev/null
i=$(awk '/./{line=$0} END{print line}' $dbid)
#Get All ID Numbers (smallest first, largest last)
cat $dbid | grep -oP '^[^0-9]*\K[0-9]+' > $lid
#Select last line of file
cat $lid | awk '/./{line=$0} END{print line}' > $sclid
i=$(awk '/./{line=$0} END{print line}' $sclid)
#Le Maths
one="1"
number=$(echo $[$i - $one])
#Add one to make it acceptable
((number++))
printf "+ ${green} You currently have $number hosts configured${nc}\n"
#Remove source
rm $dbid $lid $sclid
echo "Checking for previous installs..."
inframon2="$basedir/cpufiles/"
if [ -d "$inframon2" ]; then
  printf "${green}${inframon2} ${nc} Exists, continuing...\n"
else
  printf "+ ${red}${inframon2} ${nc} Not Found. Creating new workspace...\n"
  mkdir $basedir/cpufiles/
fi
echo ''
read -p "Please enter the HOSTNAME of the asset you wish to add: " hostname
#
#Begin Constructing Package;
#
constructfile="$basedir/cpufiles/$hostname/load-avg-monitor-$hostname.sh"
echo "#!/bin/bash" >> $constructfile
echo "#Variables" >> $constructfile
echo "mysqlusername='$mysqluser'" >> $constructfile
echo "mysqlpassword='$mysqlpass'" >> $constructfile
echo "workfile='$basedir/cpufiles/$hostname/workfile.csv'" >> $constructfile
echo "hostname=$hostname" >> $constructfile
echo "importfile='/var/lib/mysql-files/importfile.csv'" >> $constructfile
echo "#" >> $constructfile
echo 'mysql --user=$mysqlusername --password=$mysqlpassword -e "use status;SELECT ID FROM cpu;" > dbidnums.txt 2>/dev/null' >> $constructfile
echo "i=$ (awk '/./{line=$ 0} END {print line}' dbidnums.txt)" >> $constructfile
echo "#Get All ID Numbers (smallest first, largest last)" >> $constructfile
echo "cat dbidnums.txt | grep -oP '^[^0-9]*\K[0-9]+' > lastid.txt" >> $constructfile
echo "#Select last line of file" >> $constructfile
echo "cat lastid.txt | awk '/./{line=$ 0} END {print line}' > sclastid.txt" >> $constructfile
echo "i=$ (awk '/./{line=$ 0} END {print line}' sclastid.txt)" >> $constructfile
echo "#Add one" >> $constructfile
echo "((i++))" >> $constructfile
echo "#Remove source" >> $constructfile
echo "rm lastid.txt sclastid.txt dbidnums.txt" >> $constructfile
echo "# << BEGIN HOSTS >>" >> $constructfile
echo '' >> $constructfile
echo 'echo "$ i,$ hostname," >> $ workfile' >> $constructfile
echo 'cat /proc/loadavg >> $ workfile'>> $constructfile
echo "sed -i 's/ /,/g' $ workfile " >> $constructfile
echo "tr -d '\n' < $ workfile > $ importfile" >> $constructfile
echo "echo ' ' >> $ importfile" >> $constructfile
chmod 755 $basedir/cpufiles/$hostname/load-avg-monitor-$hostname.sh
chmod 755 $basedir/cpufiles/$hostname/cpu-load-monitor.sh
echo "bash $basedir/cpufiles/$hostname/cpu-load-monitor.sh" >> $constructfile
echo "exit" >> $constructfile
sed -i 's/$ i/$i/g' $constructfile
sed -i 's/$ 0/$0/g' $constructfile
sed -i 's/$ (awk/$(awk/g' $constructfile
sed -i 's/$ hostname/$hostname/g' $constructfile
sed -i 's/$ importfile/$importfile/g' $constructfile
sed -i 's/$ workfile/$workfile/g' $constructfile
printf "+ Your monitor script is available at: ${green} $constructfile ${nc}\n"
echo ''
bash $constructfile
mysql --user=$mysqluser --password=$mysqlpass -e "use status;select * from cpu;" 2>/dev/null
exit
