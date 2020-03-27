#!/bin/bash
#
#Global Variables
#MySQL Creds
mysqluser="user"
mysqlpass="pass"
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
printf "${green}           LATENCY-MONITOR-INSTALLER${nc}\n"
#
echo ''
while true; do
    read -p "Have you already configured your Network Monitor Database Credentials? (y/n): " yn
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
read -p "Please enter the HOSTNAME of the asset you wish to add: " hostname
read -p "Please enter the IP Address / Domain of the asset you wish to add: " ipaddr
read -p "Please enter the Web Server Port: " wsp
read -p "Please enter the SSH Server Port: " sshp
echo ''
echo "You have entered: "
printf "Hostname: ${green} $hostname ${nc}\n"
printf "IP Address: ${green} $ipaddr ${nc}\n"
printf "Web Server Port: ${green} $wsp ${nc}\n"
printf "SSH Server Port: ${green} $sshp ${nc}\n"
echo ''
while true; do
    read -p "Is the above information correct? (y/n): " yn
    case $yn in
        [Yy]* ) echo "Confiuguring..."; break;;
        [Nn]* ) echo "Exiting..." ; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo ''
mysqlshow --user=$mysqluser --password=$mysqlpass status >> $dbf 2>/dev/null
if grep -q "status" "$dbf"; then
        echo "Database is Existing."
    else
        mysql --user="$mysqluser" --password="$mysqlpass" -e "CREATE DATABASE IF NOT EXISTS status;"
fi
rm $dbf
#****************************
#START Database Configuration
#****************************
echo "Checking Database Configuration..."
mysqlshow --user=$mysqluser --password=$mysqlpass status >> $dbf 2>/dev/null
if grep -q "srv" "$dbf"; then
        printf "${green}Table 'status.srv' exists, continuing...${nc}\n"
fi
if ! grep -q "srv" "dbfile.txt"; then
        printf "${red}Table 'status.srv' Doesn't exist, Installing...${nc}\n"
        mysql --user=$mysqluser --password=$mysqlpass -e "USE status;CREATE TABLE srv (id INT AUTO_INCREMENT NOT NULL, hostname VARCHAR(255) NOT NULL, lastping VARCHAR(255) NOT NULL, PRIMARY KEY (id));" 2>/dev/null
        mysqlshow --user=$mysqluser --password=$mysqlpass status >> $dbf1 2>/dev/null
	if grep -q "srv" "$dbf1"; then
	printf "${green}Table 'status.srv' has been created, continuing...${nc}\n"
	fi
fi
rm $dbf $dbf1
#
echo "Checking Historical Database Configuration..."
mysqlshow --user=$mysqluser --password=$mysqlpass status >> $dbf 2>/dev/null
if grep -q "hist_srv" "$dbf"; then
        printf "${green}Table 'status.hist_srv' exists, continuing...${nc}\n"
fi
if ! grep -q "hist_srv" "$dbf"; then
        printf "${red}Table 'status.hist_srv' Doesn't exist, Installing...${nc}\n"
        mysql --user=$mysqluser --password=$mysqlpass -e "USE status;CREATE TABLE hist_srv (id INT NOT NULL, hostname VARCHAR(255) NOT NULL, lastping VARCHAR(255) NOT NULL, importtime VARCHAR(255) NOT NULL, random VARCHAR(255) NOT NULL, PRIMARY KEY (random));" 2>/dev/null
    mysqlshow --user=$mysqluser --password=$mysqlpass status >> $dbf1 2>/dev/null
	if grep -q "hist_srv" "$dbf1"; then
	printf "${green}Table 'status.hist_srv' has been created, continuing...${nc}\n"
	fi
fi
rm $dbf $dbf1
#
echo "Configuring Database for new entry..."
#Get the ID numbers from the current database, add one, and use that as the ID for the new one.
mysql --user=$mysqluser --password=$mysqlpass -e "use status;SELECT ID FROM srv;" > $dbid 2>/dev/null
i=$(awk '/./{line=$0} END{print line}' $dbid)
#Add one to make it acceptable
((i++))
#Import Web Server
mysql --user=$mysqluser --password=$mysqlpass -e "USE status; INSERT INTO srv (id, hostname, lastping) VALUES ('$i','$hostname Web Server','Awaiting Configuration');" 2>/dev/null
#Check
echo "Web Server Inserted with ID Number $i: "
mysql --user=$mysqluser --password=$mysqlpass -e "USE status; SELECT * FROM srv WHERE id = '$i';" 2>/dev/null
#Add another for the SSH Server
((i++))
#Import
mysql --user=$mysqluser --password=$mysqlpass -e "USE status; INSERT INTO srv (id, hostname, lastping) VALUES ('$i','$hostname SSH Server','Awaiting Configuration');" 2>/dev/null
#Check
echo "SSH Server Inserted with ID Number $i: "
mysql --user=$mysqluser --password=$mysqlpass -e "USE status; SELECT * FROM srv WHERE id = '$i';" 2>/dev/null
#Remove source
rm $dbid
#**************************
#END Database Configuration
#**************************
#**************************
#START Script Configuration
#**************************
echo "Configuring Script for new entry..."
#Get Current Amount of Configured Assets
mysql --user=$mysqluser --password=$mysqlpass -e "use status;SELECT ID FROM srv;" > $dbid 2>/dev/null
i=$(awk '/./{line=$0} END{print line}' $dbid)
#legacy:
#Get All ID Numbers (smallest first, largest last)
cat $dbid | grep -oP '^[^0-9]*\K[0-9]+' > $lid
#echo "ID Numbers to be configured: "
#Select last line of file
cat $lid | awk '/./{line=$0} END{print line}' > $sclid
i=$(awk '/./{line=$0} END{print line}' $sclid)
two="2"
number=$(echo $[$i - $two])
#Add one to make it acceptable
((number++))
#echo "Web Server ID: " $number
#Add another for SS
((number++))
#echo "SSH Server ID: " $number
#Remove source
rm $lid $sclid $dbid
#Perform maths, for reasons
#Web Maths:
two="2"
filenum=$(echo $[$i - $two])
filenumname="file$filenum='"
((filenum ++))
#echo "Web Server ID to be inserted:"
#echo "file$filenum"
#Build file name
webfilename=$(echo "file$filenum='$basedir/tempfiles/file$filenum.csv'")
#echo "Web File Name:"
#echo $webfilename
#sed -i "/$filenumname/a $webfilename" /root/scripts/SECSUITE/inframon/net-monitor.sh
#echo "Your Web file inside the script:"
#cat /root/scripts/SECSUITE/inframon/net-monitor.sh | grep -E "$webfilename"
#SSH Maths:
one="1"
filenumssh=$(echo $[$i - $one])
filenumnamessh="file$filenumssh='"
((filenumssh ++))
#echo "SSH Server ID to be inserted:"
#echo "file$filenumssh"
#Build file name
sshfilename=$(echo "file$filenumssh='$basedir/tempfiles/file$filenumssh.csv'")
#echo "SSH File Name:"
#echo $sshfilename
#sed -i "/$filenumnamessh/a $sshfilename" /root/scripts/SECSUITE/inframon/net-monitor.sh
#echo "Your SSH file inside the script:"
#cat /root/scripts/SECSUITE/inframon/net-monitor.sh | grep -E "$sshfilename"
#**************************
#END Script Configuration
#**************************
#fi
#**************************
#IF Script isn't Existing:
#**************************
#Add rows in DB for first 2 devices:
mysql --user=$mysqluser --password=$mysqlpass -e "USE status; INSERT INTO srv (id, hostname, lastping) VALUES ('1','$hostname Web Server','Awaiting Configuration');" 2>/dev/null
mysql --user=$mysqluser --password=$mysqlpass -e "USE status; INSERT INTO srv (id, hostname, lastping) VALUES ('2','$hostname SSH Server','Awaiting Configuration');" 2>/dev/null
#**************************
#START Script Creation
#**************************
#Define Variables for passing;
buildfile="$basedir/latency-files/$hostname-latency-monitor.sh"
echo "#!/bin/bash" >> $buildfile
echo "#" >> $buildfile
echo "#Global Variables" >> $buildfile
echo "user='$mysqluser'" >> $buildfile
echo "pass='$mysqlpass'" >> $buildfile
echo "#" >> $buildfile
echo "red='\033[0;31m'" >> $buildfile
echo "green='\033[0;32m'" >> $buildfile
echo "nc='\033[0m'" >> $buildfile
echo "#" >> $buildfile
echo "file01='$basedir/tempfiles/01.csv'" >> $buildfile
echo "file02='$basedir/tempfiles/02.csv'" >> $buildfile
echo "#" >> $buildfile
echo "# << BEGIN HOSTS >>" >> $buildfile
echo "#" >> $buildfile
#**************************
#START Host Web Server
#**************************
echo "#'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'" >> $buildfile
echo "#" >> $buildfile
echo "#Host: $hostname (Web Server)" >> $buildfile
echo "#" >> $buildfile
echo "sleep 1" >> $buildfile
echo "hostdev=$ipaddr" >> $buildfile
echo "nmap $ hostdev -p$wsp 1>/dev/null 2>/dev/null" >> $buildfile
echo "SUCCESS= $ ?" >> $buildfile
echo "if [ $ SUCCESS -eq 0 ]" >> $buildfile
echo "then" >> $buildfile
echo "  nmap $ hostdev -p$wsp > $ file01" >> $buildfile
echo "  lastping01=$ (cat $ file01 | grep 'latency')" >> $buildfile
echo "mysql --user=$ user --password=$ pass -e " >> $qry1
echo '"' >> $qry1
echo "use status;update srv set lastping = '$ lastping01' where id='$filenum';" >> $qry1
echo '"' >> $qry1
echo " 2>/dev/null ; " >> $qry1
tr -d '\n' < $qry1 >> $buildfile
rm $qry1
echo "else" >> $buildfile
echo "  nmap $ hostdev -p$wsp > $ file01" >> $buildfile
echo "  lastping01=$ (cat $ file01 | grep 'latency')" >> $buildfile
echo "  mysql --user=$ user --password=$ pass -e " >> $qry2
echo '"' >> $qry2
echo "use status;update srv set lastping = '$ lastping01' where id='$filenum';" >> $qry2
echo '"' >> $qry2
echo " 2>/dev/null ; " >> $qry2
tr -d '\n' < $qry2 >> $buildfile
rm $qry2
echo "fi" >> $buildfile
echo "#EOF" >> $buildfile
echo "#'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'" >> $buildfile
#**************************
#START Processing
#**************************
sed -i 's/$ user/$user/g' $buildfile
sed -i 's/$ pass/$pass/g' $buildfile
sed -i 's/$ (cat/$(cat/g' $buildfile
sed -i 's/SUCCESS= $ ?/SUCCESS=$?/g' $buildfile
sed -i 's/$ file01/$file01/g' $buildfile
sed -i 's/$ hostdev/$hostdev/g' $buildfile
sed -i 's/$ lastping01/$lastping01/g' $buildfile
#**************************
#START Host SSH Server
#**************************
((i++))
echo "#'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'" >> $buildfile
echo "#" >> $buildfile
echo "#Host: $hostname (SSH Server)" >> $buildfile
echo "#" >> $buildfile
echo "sleep 1" >> $buildfile
echo "hostdev=$ipaddr" >> $buildfile
echo "nmap $ hostdev -p$sshp 1>/dev/null 2>/dev/null" >> $buildfile
echo "SUCCESS= $ ?" >> $buildfile
echo "if [ $ SUCCESS -eq 0 ]" >> $buildfile
echo "then" >> $buildfile
echo "  nmap $ hostdev -p$sshp > $ file02" >> $buildfile
echo "  lastping02=$ (cat $ file02 | grep 'latency')" >> $buildfile
echo "mysql --user=$ user --password=$ pass -e " >> $qry1
echo '"' >> $qry1
echo "use status;update srv set lastping = '$ lastping02' where id='$filenumssh';" >> $qry1
echo '"' >> $qry1
echo " 2>/dev/null ; " >> $qry1
tr -d '\n' < $qry1 >> $buildfile
rm $qry1
echo "else" >> $buildfile
echo "  nmap $ hostdev -p$sshp > $ file02" >> $buildfile
echo "  lastping02=$ (cat $ file02 | grep 'latency')" >> $buildfile
echo "  mysql --user=$ user --password=$ pass -e " >> $qry2
echo '"' >> $qry2
echo "use status;update srv set lastping = '$ lastping02' where id='$filenumssh';" >> $qry2
echo '"' >> $qry2
echo " 2>/dev/null ; " >> $qry2
tr -d '\n' < $qry2 >> $buildfile
rm $qry2
echo "fi" >> $buildfile
echo 'mysql --user=$ user --password=$ pass -e "USE status;INSERT INTO hist_srv (id, hostname, lastping, random, importtime) SELECT *, RAND(), CURRENT_TIMESTAMP() FROM srv;" 2>/dev/null' >> $buildfile
echo "rm $ file01 $ file02" >> $buildfile
echo "#'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'" >> $buildfile
#**************************
#START Processing
#**************************
sed -i 's/$ user/$user/g' $buildfile
sed -i 's/$ pass/$pass/g' $buildfile
sed -i 's/$ (cat/$(cat/g' $buildfile
sed -i 's/SUCCESS= $ ?/SUCCESS=$?/g' $buildfile
sed -i 's/$ SUCCESS/$SUCCESS/g' $buildfile
sed -i 's/$ file01/$file01/g' $buildfile
sed -i 's/$ file02/$file02/g' $buildfile
sed -i 's/$ hostdev/$hostdev/g' $buildfile
sed -i 's/$ lastping02/$lastping02/g' $buildfile
#**************************
#START Verifications
#**************************
echo ''
echo "Your current hosts: "
mysql --user=$mysqluser --password=$mysqlpass -e "USE status; SELECT * FROM srv;" 2>/dev/null
echo ''
echo "Your network monitor script for $hostname: "
FILE=$basedir/latency-files/$hostname-latency-monitor.sh
if test -f "$FILE"; then
    printf "+ ${green} $FILE ${nc} has been created successfully. Executing...\n"
    bash $basedir/latency-files/$hostname-latency-monitor.sh
    mysql --user="$mysqluser" --password="$mysqlpass" -e "use status; select * from srv;" 2>/dev/null
    mysql --user="$mysqluser" --password="$mysqlpass" -e "use status; select * from hist_srv;" 2>/dev/null
fi
exit
