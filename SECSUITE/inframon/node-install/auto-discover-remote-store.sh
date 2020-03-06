#!/bin/bash
#
# ____  _____ ____ ____  _   _ ___ _____ _____
#/ ___|| ____/ ___/ ___|| | | |_ _|_   _| ____|
#\___ \|  _|| |   \___ \| | | || |  | | |  _|
# ___) | |__| |___ ___) | |_| || |  | | | |___
#|____/|_____\____|____/ \___/|___| |_| |_____|
#       AUTO-DISCOVER HOSTS
#
#
#Global Variables
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
printf "${green}       AUTO-DISCOVER-HOST-COMPONENT${nc}\n"
#
echo ''
echo "Welcome to the SECSUITE Auto-Discover Set-Up!"
echo "You have chosen to install: " ; printf "${green}Remote Node Local${nc}\n"
echo ''
#
#Find out current IP and VLAN;
ip addr show > netfile.txt
#Get IPv4
cat netfile.txt | grep -E 'inet' > inetfile.txt
#Exclude localhost & broadcast addresses
sed -i "s/127.0.0.1/localhost-doesn't-count/g" inetfile.txt
sed -i "s/255//g" inetfile.txt
#Print remaining IPs into file;
cat inetfile.txt | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' | awk '{print $0}' > ipaddrfile.txt
#
#Get Server IP;
myip=$(cat ipaddrfile.txt)
echo "Your IP Address is:"
printf "${green}"
echo $myip
printf "${nc}\n"
#
#Separate the digits with commast instead;
sed -i "s/\./ , /g" ipaddrfile.txt
#Begin Process;
while true; do
    read -p "Do you wish to run the Auto-Discover feature on the $(printf ${green}) $(awk '{print $1".",$3".",$5"."}' ipaddrfile.txt) 0 /24 $(printf ${nc})network? (Y/n): " yn
    case $yn in
        [Yy]* ) sudo nmap -sP -q 192.168.$(awk '{ print $5 }' ipaddrfile.txt).0/24 > nmapfile.txt 2>/dev/null; break;;
        [Nn]* ) echo "Exiting." ; rm ipaddrfile.txt inetfile.txt netfile.txt ; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
#
#Discard routers
cat nmapfile.txt | grep -v "router.movistar" > sanitised.txt
#Process responding devices
cat sanitised.txt | grep -E "Nmap scan report for" > nmapfiltered.txt
#Get IPs
cat nmapfiltered.txt | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' | awk '{print $0}' > final-ips.txt
#File checks
if grep -q '.' "nmapfiltered.txt"; then
  echo ''
  printf "+ ${green} The following hosts have been found:${nc}\n\n"
  cat nmapfiltered.txt
  else
  echo ''
  printf "${red}Uh-Oh! We have encountered an error!\n"
fi
if grep -q '.' "final-ips.txt"; then
  echo ''
  printf "+ ${green} The following host IP addresses have been found:${nc}\n\n"
  cat final-ips.txt
  else
  echo ''
  printf "${red}Uh-Oh! We have encountered an error!\n"
fi
if grep -q $myip "final-ips.txt"; then
  echo ''
  printf "+ ${red} Your host Server IP addres has been found, and will require a Standard Installation.${nc}\n\n"
  cat final-ips.txt | grep -E $myip
  else
  echo ''
  printf "${red}Uh-Oh! We have encountered an error!\n"
fi
echo ''
unset option menu ERROR      # prevent inheriting values from the shell
declare -a menu              # create an array called $menu
menu[0]=""                   # set and ignore index zero so we can count from 1
# read menu file line-by-line, save as $line
while IFS= read -r line; do
  menu[${#menu[@]}]="$line"  # push $line onto $menu[]
done < final-ips.txt
# function to show the menu
menu() {
  printf "Please select a host by typing in the corresponding ${green} ID ${nc} number: "
  echo ""
  for (( i=1; i<${#menu[@]}; i++ )); do
    printf "${green} $i${nc}) ${menu[$i]}\n"
  done
  echo ""
}
# initial menu
menu
read option
# loop until given a number with an associated menu item
while ! [ "$option" -gt 0 ] 2>/dev/null || [ -z "${menu[$option]}" ]; do
  echo "Option '$option' is not available." >&2  # output this to standard error
  menu
  read option
done
echo "You said '$option' which corresponds to: '${menu[$option]}'" > optionfile.txt
if grep -q $myip "optionfile.txt"; then
  echo ''
  printf "+ ${red} Your host Server IP addres has been found, and will require a Standard Installation.\nPlease do not install over the network for localhost!!${nc}\n\n" ; exit
  else
  echo ''
  printf "${green}Beginning installation process on ${menu[$option]}${nc}\n"
fi
read -p "Please introduce a new HOSTNAME for ${menu[$option]}: " hostname
echo ""
#Prepare Installation Script;
#
installscript="/root/scripts/SECSUITE/preinstall.sh"
echo "#!/bin/bash" >> $installscript
echo "#ASCII Colours" >> $installscript
echo "red='\033[0;31m'" >> $installscript
echo "green='\033[0;32m'" >> $installscript
echo "nc='\033[0m'" >> $installscript
#
echo "#" >> $installscript
#Dir1
echo "echo '+ Directory Setup:'" >> $installscript
echo "echo '------------------'"  >> $installscript
echo 'if [ -d "/root/scripts/" ]; then' >> $installscript
echo '  printf " -> /root/scripts/ ${green}✓${nc}\n"' >> $installscript
echo '    else' >> $installscript
echo '  printf " -> /root/scripts/ ${red}X${nc}\n"' >> $installscript
echo '  printf "+ Creating /root/scripts/ (base directory)\n"' >> $installscript
echo '  mkdir /root/scripts/' >> $installscript
echo '  if [ -d "/root/scripts/" ]; then' >> $installscript
echo '        printf " -> /root/scripts/ ${green}✓${nc}\n"' >> $installscript
echo '  fi' >> $installscript
echo 'fi' >> $installscript
#Dir2
echo 'if [ -d "/root/scripts/SECSUITE/" ]; then' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/ ${green}✓${nc}\n"' >> $installscript
echo '    else' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/ ${red}X${nc}\n"' >> $installscript
echo '        printf "+ Creating /root/scripts/SECSUITE/ (active working directory)\n"' >> $installscript
echo '        mkdir /root/scripts/SECSUITE/' >> $installscript
echo '  if [ -d "/root/scripts/SECSUITE/" ]; then' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/ ${green}✓${nc}\n"' >> $installscript
echo '        fi' >> $installscript
echo 'fi' >> $installscript
#Dir3
echo 'if [ -d "/root/scripts/SECSUITE/inframon/" ]; then' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/inframon/ ${green}✓${nc}\n"' >> $installscript
echo '    else' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/inframon/ ${red}X${nc}\n"' >> $installscript
echo '        printf "+ Creating /root/scripts/SECSUITE/inframon/ (active working directory)\n"' >> $installscript
echo '        mkdir /root/scripts/SECSUITE/inframon/' >> $installscript
echo '  if [ -d "/root/scripts/SECSUITE/inframon/" ]; then' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/inframon/ ${green}✓${nc}\n"' >> $installscript
echo '        fi' >> $installscript
echo 'fi' >> $installscript
#Dir4
echo 'if [ -d "/root/scripts/SECSUITE/inframon/cpufiles/" ]; then' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/inframon/cpufiles/ ${green}✓${nc}\n"' >> $installscript
echo '    else' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/inframon/cpufiles/ ${red}X${nc}\n"' >> $installscript
echo '        printf "+ Creating /root/scripts/SECSUITE/inframon/cpufiles/ (active working directory)\n"' >> $installscript
echo '        mkdir /root/scripts/SECSUITE/inframon/cpufiles/' >> $installscript
echo '  if [ -d "/root/scripts/SECSUITE/inframon/cpufiles/" ]; then' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/inframon/cpufiles/ ${green}✓${nc}\n"' >> $installscript
echo '        fi' >> $installscript
echo 'fi' >> $installscript
#Dir5
echo 'if [ -d "/root/scripts/SECSUITE/inframon/latency-files/" ]; then' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/inframon/latency-files/ ${green}✓${nc}\n"' >> $installscript
echo '    else' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/inframon/latency-files/ ${red}X${nc}\n"' >> $installscript
echo '        printf "+ Creating /root/scripts/SECSUITE/inframon/latency-files/ (active working directory)\n"' >> $installscript
echo '        mkdir /root/scripts/SECSUITE/inframon/latency-files/' >> $installscript
echo '  if [ -d "/root/scripts/SECSUITE/inframon/latency-files/" ]; then' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/inframon/latency-files/ ${green}✓${nc}\n"' >> $installscript
echo '        fi' >> $installscript
echo 'fi' >> $installscript
#Dir6
echo 'if [ -d "/root/scripts/SECSUITE/inframon/apachestatus/" ]; then' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/inframon/apachestatus/ ${green}✓${nc}\n"' >> $installscript
echo '    else' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/inframon/apachestatus/ ${red}X${nc}\n"' >> $installscript
echo '        printf "+ Creating /root/scripts/SECSUITE/inframon/apachestatus/ (active working directory)\n"' >> $installscript
echo '        mkdir /root/scripts/SECSUITE/inframon/apachestatus/' >> $installscript
echo '  if [ -d "/root/scripts/SECSUITE/inframon/apachestatus/" ]; then' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/inframon/apachestatus/ ${green}✓${nc}\n"' >> $installscript
echo '        fi' >> $installscript
echo 'fi' >> $installscript
#Dir7
echo 'if [ -d "/root/scripts/SECSUITE/inframon/temperaturefiles/" ]; then' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/inframon/temperaturefiles/ ${green}✓${nc}\n"' >> $installscript
echo '    else' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/inframon/temperaturefiles/ ${red}X${nc}\n"' >> $installscript
echo '        printf "+ Creating /root/scripts/SECSUITE/inframon/temperaturefiles/ (active working directory)\n"' >> $installscript
echo '        mkdir /root/scripts/SECSUITE/inframon/temperaturefiles/' >> $installscript
echo '  if [ -d "/root/scripts/SECSUITE/inframon/temperaturefiles/" ]; then' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/inframon/temperaturefiles/ ${green}✓${nc}\n"' >> $installscript
echo '        fi' >> $installscript
echo 'fi' >> $installscript
#Dir8
echo 'if [ -d "/root/scripts/SECSUITE/inframon/temperaturefiles/resources/" ]; then' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/inframon/temperaturefiles/resources/ ${green}✓${nc}\n"' >> $installscript
echo '    else' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/inframon/temperaturefiles/resources/ ${red}X${nc}\n"' >> $installscript
echo '        printf "+ Creating /root/scripts/SECSUITE/inframon/temperaturefiles/resources/ (active working directory)\n"' >> $installscript
echo '        mkdir /root/scripts/SECSUITE/inframon/temperaturefiles/resources/' >> $installscript
echo '  if [ -d "/root/scripts/SECSUITE/inframon/temperaturefiles/resources/" ]; then' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/inframon/temperaturefiles/resources/ ${green}✓${nc}\n"' >> $installscript
echo '        fi' >> $installscript
echo 'fi' >> $installscript
#Dir9
echo 'if [ -d "/root/scripts/SECSUITE/inframon/tempfiles/" ]; then' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/inframon/tempfiles/ ${green}✓${nc}\n"' >> $installscript
echo '    else' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/inframon/tempfiles/ ${red}X${nc}\n"' >> $installscript
echo '        printf "+ Creating /root/scripts/SECSUITE/inframon/tempfiles/ (active working directory)\n"' >> $installscript
echo '        mkdir /root/scripts/SECSUITE/inframon/tempfiles/' >> $installscript
echo '  if [ -d "/root/scripts/SECSUITE/inframon/tempfiles/" ]; then' >> $installscript
echo '        printf " -> /root/scripts/SECSUITE/inframon/tempfiles/ ${green}✓${nc}\n"' >> $installscript
echo '        fi' >> $installscript
echo 'fi' >> $installscript
#
read -p "Enter SSH User (root recommended): " sudousr
while true; do
    read -p "Is ${menu[$option]} running SSH on port 22? (Y/n): " yn
    case $yn in
        [Yy]* ) rhostport="22" ; break;;
        [Nn]* ) read -p "Please insert the SSH port number: " rhostport ; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
#Define IP
ipaddr=$(echo "${menu[$option]}")
#Will require password if you haven't copied the SSH ID (ssh-copy-id)
rsync -avzh -e "ssh -p $rhostport" $installscript $sudousr@$ipaddr:/root/ --quiet
#Will require password if you haven't copied the SSH ID (ssh-copy-id)
ssh -p $rhostport $sudousr@$ipaddr chmod 755 /root/preinstall.sh
#Will require password if you haven't copied the SSH ID (ssh-copy-id)
ssh -p $rhostport $sudousr@$ipaddr bash /root/preinstall.sh
#
#
echo ''
#
printf "${green}Let's configure the database credentials for the installation:${nc}\n"
printf "${green}Note: You will only have to configure this once, and you do have the option to change credentials in other components.${nc}\n"
echo ''
read -p "Please enter an Administrative Remote MySQL User on the Node: " mysqluser
read -s -p "Please enter $mysqluser's MySQL Password on the Remote Node: " mysqlpass
echo ""
#
#Configure Apache Monitor;
#
#Begin
#
printf "${green} ____  _____ ____ ____  _   _ ___ _____ _____${nc}\n"
printf "${green}/ ___|| ____/ ___/ ___|| | | |_ _|_   _| ____|${nc}\n"
printf "${green}\___ \|  _|| |   \___ \| | | || |  | | |  _|${nc}\n"
printf "${green} ___) | |__| |___ ___) | |_| || |  | | | |___${nc}\n"
printf "${green}|____/|_____\____|____/ \___/|___| |_| |_____|${nc}\n"
printf "${green}       APACHE-STATUS-REMOTE-INSTALLER${nc}\n"
#
#Begin Construction
#
constructfile="/root/scripts/SECSUITE/inframon/node-install/apache-monitor-$hostname.sh"
#
echo ''
echo "#!/bin/bash" >> $constructfile
echo "# Colours" >> $constructfile
echo "lightgreen='\033[1;32m'" >> $constructfile
echo "lightpurple='\033[1;35m'" >> $constructfile
echo "red='\033[0;31m'" >> $constructfile
echo "nc='\033[0m'" >> $constructfile
echo "#" >> $constructfile
echo "mysqluser='$mysqluser'" >> $constructfile
echo "mysqlpass='$mysqlpass'" >> $constructfile
echo "#" >> $constructfile
echo "statusfile='/root/scripts/SECSUITE/inframon/apachestatus/statusfile.txt'" >> $constructfile
echo "statusfile1='/root/scripts/SECSUITE/inframon/apachestatus/statusfile1.txt'" >> $constructfile
echo "statusfilenonl='/var/lib/mysql-files/importapachestatus.csv'" >> $constructfile
echo "#" >> $constructfile
echo "service apache2 status >> $ statusfile" >> $constructfile
echo 'if [ ! -f "$ statusfile" ]' >> $constructfile
echo "then" >> $constructfile
echo '        #printf "+  ${red} STATUS FILE NOT FOUND!!!${nc}\n\n"' >> $constructfile
echo '        echo "exiting"' >> $constructfile
echo "        exit" >> $constructfile
echo "fi" >> $constructfile
echo '        #printf "+  Status file created: ${lightgreen}OK${nc}\n\n"' >> $constructfile
echo "#" >> $constructfile
echo 'cat $ statusfile | grep -E "Active" > $ statusfile1' >> $constructfile
echo 'mysql --user=$ mysqluser --password=$ mysqlpass -e "use status;truncate table apachestatus;" 2>/dev/null' >> $constructfile

#
echo "Checking database for entries..."
mysqlshow -h $ipaddr --user="$mysqluser" --password="$mysqlpass" status >> dbfile.txt 2>/dev/null
if grep -q apachestatus "dbfile.txt"; then
        printf "${green} Table 'status.apachestatus' exists, continuing...${nc}\n"
        echo "Getting new ID for $hostname..."
        #Get the ID numbers from the current database, add one, and use that as the ID for the new one.
        mysql -h"$ipaddr" -D'status' --user="$mysqluser" --password="$mysqlpass" -e "SELECT ID FROM apachestatus;" > dbidnums.txt 2>/dev/null
        i=$(awk '/./{line=$0} END{print line}' dbidnums.txt)
        #Add one to make it acceptable
        ((i++))
        printf "+ The new ID has been generated: ${green} $i ${nc}\n"
        rm dbidnums.txt
fi
if ! grep -q apachestatus "dbfile.txt"; then
        printf "${red} Table 'status.apachestatus' Doesn't exist, Installing...${nc}\n"
        mysql -h $ipaddr -D'status' --user="$mysqluser" --password="$mysqlpass" -e "CREATE TABLE apachestatus (id INT AUTO_INCREMENT NOT NULL, hostname VARCHAR(255) NOT NULL, apachestatus VARCHAR(255) NOT NULL, PRIMARY KEY (id));" 2>/dev/null
        mysqlshow -h"$ipaddr" --user="$mysqluser" --password="$mysqlpass" status >> dbfile2.txt 2>/dev/null
        if grep -q apachestatus "dbfile2.txt"; then
        printf "${green} Table 'status.apachestatus' has been created, continuing...${nc}\n"
        fi
        rm dbfile2.txt
fi
rm dbfile.txt
#
echo "sed -i '1 i\ $i, $hostname,' $ statusfile1" >> $constructfile
echo 'tr -d "\n\r" < $ statusfile1 > /var/lib/mysql-files/importapachestatus.csv' >> $constructfile
echo 'mysql --user=$ mysqluser --password=$ mysqlpass -e "USE status;LOAD DATA INFILE ' >> qry1.txt
echo "'/var/lib/mysql-files/importapachestatus.csv' INTO TABLE apachestatus FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';" >> qry1.txt
echo '"' >> qry1.txt
tr -d '\n' < qry1.txt >> qry2.txt
cat qry2.txt >> $constructfile
rm qry1.txt qry2.txt
echo 'mysql --user=$ mysqluser --password=$ mysqlpass -e "use status;update select * from apachestatus;" 2>/dev/null' >> $constructfile
echo 'mysql --user=$ mysqluser --password=$ mysqlpass -e "use status;INSERT INTO hist_apachestatus SELECT *, CURRENT_TIMESTAMP() FROM apachestatus;" 2>/dev/null' >> $constructfile
echo "rm $ statusfile $ statusfile2 $ statusfile1 $ statusfilenonl" >> $constructfile
#
sed -i 's/$ mysqluser/$mysqluser/g' $constructfile
sed -i 's/$ mysqlpass/$mysqlpass/g' $constructfile
sed -i 's/$ statusfile/$statusfile/g' $constructfile
sed -i 's/$ statusfile2/$statusfile2/g' $constructfile
sed -i 's/$ statusfile1/$statusfile1/g' $constructfile
sed -i 's/$ statusfilemon1/$statusfilemon1/g' $constructfile
#
echo "Sending Monitor..."
rsync -avzh -e "ssh -p $rhostport" $constructfile $sudousr@$ipaddr:/root/scripts/SECSUITE/inframon/apachestatus/ --quiet
ssh -p $rhostport $sudousr@$ipaddr chmod 755 /root/scripts/SECSUITE/inframon/apachestatus/apache-monitor-$hostname.sh
ssh -p $rhostport $sudousr@$ipaddr "ls /root/scripts/SECSUITE/inframon/apachestatus/apache-monitor-$hostname.sh" >> apachemonitorcheck.txt
#
if grep -q /root/scripts/SECSUITE/inframon/apachestatus/apache-monitor-$hostname.sh "apachemonitorcheck.txt"; then
    printf "+ ${green} /root/scripts/SECSUITE/inframon/apachestatus/apache-monitor-$hostname.sh${nc} has been created successfully.\n"
    rm apachemonitorcheck.txt
  else
    printf "+ ${red} $hostname-latency-monitor.sh ${nc}has not been created! ${red}(X)${nc}\n"
    rm apachemonitorcheck.txt
fi
#
#Configure CPU Load Averages;
#
#Begin
#
printf "${green} ____  _____ ____ ____  _   _ ___ _____ _____${nc}\n"
printf "${green}/ ___|| ____/ ___/ ___|| | | |_ _|_   _| ____|${nc}\n"
printf "${green}\___ \|  _|| |   \___ \| | | || |  | | |  _|${nc}\n"
printf "${green} ___) | |__| |___ ___) | |_| || |  | | | |___${nc}\n"
printf "${green}|____/|_____\____|____/ \___/|___| |_| |_____|${nc}\n"
printf "${green}       CPU-LOAD-AVERAGE-REMOTE-INSTALLER${nc}\n"
#
while true; do
    read -p "Do you wish to use $mysqluser as the MySQL user? (y/n): " yn
    case $yn in
        [Yy]* ) echo "Skipping Credential Input."; break;;
        [Nn]* ) echo ""
                read -p "Please enter an Administrative MySQL User on the Remote Node: " mysqluser
                read -s -p "Please enter $mysqluser's MySQL Password on the Remote Node: " mysqlpass
                break;;
        * ) echo "Please answer yes or no.";;
    esac
done
#
echo ''
echo "Checking for active host installs..."
ssh -p $rhostport $sudousr@$ipaddr ls /root/scripts/SECSUITE/inframon/cpufiles/ > inframon.txt
if grep -q $hostname "inframon.txt"; then
        printf "+ ${red} $hostname ${nc} Already Exists. Exiting.\n" ; rm inframon.txt ; exit
    else
        printf "+ Creating${green} $hostname${nc}...\n"
        ssh -p $rhostport $sudousr@$ipaddr mkdir /root/scripts/SECSUITE/inframon/cpufiles/$hostname/
fi
rm inframon.txt
echo "Do you wish to name this host $hostname? (y/n): "
select yn in "Yes" "No"; do
    case $yn in
        Yes ) ssh -p $rhostport $sudousr@$ipaddr mkdir /root/scripts/SECSUITE/inframon/cpufiles/$hostname/ ; break;;
        No ) read -p "Please enter the identifying HOSTNAME of the asset you wish to add: " hostname ; ssh -p $rhostport $sudousr@$ipaddr mkdir /root/scripts/SECSUITE/inframon/cpufiles/$hostname/ ; break;;
    esac
done
#
echo ''
#
#Begin Constructing Package;
#
cpumonitor="/root/scripts/SECSUITE/inframon/node-install/cpu-load-monitor.sh"
#
    printf "+ ${green} $hostname ${nc} will be created...\n"
    touch $cpumonitor
        echo "#!/bin/bash" >> $cpumonitor
        echo "#" >> $cpumonitor
        echo "#Variables" >> $cpumonitor
        echo "#" >> $cpumonitor
        echo "#MySQL Creds" >> $cpumonitor
        echo "mysqluser='$mysqluser'" >> $cpumonitor
        echo "mysqlpass='$mysqlpass'" >> $cpumonitor
        echo "#" >> $cpumonitor
        echo "hostnamefile='/root/scripts/SECSUITE/inframon/cpufiles/$hostname/workfile.csv'" >> $cpumonitor
        echo "hostname=$hostname" >> $cpumonitor
        echo "importfile='/var/lib/mysql-files/cpuimport.csv'" >> $cpumonitor
        echo "tr -d '\n' < $ hostnamefile > $ importfile" >> $cpumonitor
        echo "echo ' ' >> $ importfile" >> $cpumonitor
        echo "mysql --user=$ mysqluser --password=$ mysqlpass -e " >> qry1.txt
        echo '"USE status; truncate table cpu;" 2>/dev/null ' >> qry1.txt
        tr -d '\n' < qry1.txt > qry2.txt
        cat qry2.txt >> $cpumonitor
        rm qry1.txt qry2.txt
        echo "" >> $cpumonitor
        echo "mysql --user=$ mysqluser --password=$ mysqlpass -e " >> qry1.txt
        echo '"' >> qry1.txt
        echo "USE status;LOAD DATA INFILE '/var/lib/mysql-files/cpuimport.csv' INTO TABLE cpu FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';" >> qry1.txt
        echo '"' >> qry1.txt
        echo " 2>/dev/null" >> qry1.txt
        tr -d '\n' < qry1.txt > qry2.txt
        cat qry2.txt >> $cpumonitor
        rm qry1.txt qry2.txt
        echo "" >> $cpumonitor
        echo 'mysql --user=$ mysqluser --password=$ mysqlpass -e "use status;INSERT INTO hist_cpu SELECT *, CURRENT_TIMESTAMP() FROM cpu;" 2>/dev/null' >> $cpumonitor
        echo "rm $ hostnamefile $ importfile" >> $cpumonitor
        echo "exit" >> $cpumonitor
#Process the monitor
        sed -i 's/$ mysqluser/$mysqluser/g' $cpumonitor
        sed -i 's/$ mysqlpass/$mysqlpass/g' $cpumonitor
        sed -i 's/$ importfile/$importfile/g' $cpumonitor
        sed -i 's/$ hostname/$hostname/g' $cpumonitor
        sed -i 's/$ hostname.csv/$hostname.csv/g' $cpumonitor
        sed -i 's/$ hostnamefile/$hostnamefile/g' $cpumonitor

        echo "Sending CPU Monitor..."
        rsync -avzh -e "ssh -p $rhostport" $cpumonitor $sudousr@$ipaddr:/root/scripts/SECSUITE/inframon/cpufiles/$hostname/ --quiet
        rm $cpumonitor
#
#Configure CPU Node
#
#Begin
#
printf "${green} ____  _____ ____ ____  _   _ ___ _____ _____${nc}\n"
printf "${green}/ ___|| ____/ ___/ ___|| | | |_ _|_   _| ____|${nc}\n"
printf "${green}\___ \|  _|| |   \___ \| | | || |  | | |  _|${nc}\n"
printf "${green} ___) | |__| |___ ___) | |_| || |  | | | |___${nc}\n"
printf "${green}|____/|_____\____|____/ \___/|___| |_| |_____|${nc}\n"
printf "${green}    CPU-LOAD-AVERAGE-REMOTE-NODE-MONITOR${nc}\n"
#
while true; do
    read -p "Do you wish to use $mysqluser as the MySQL user? (y/n): " yn
    case $yn in
        [Yy]* ) echo "Skipping Credential Input."; break;;
        [Nn]* ) echo ""
                read -p "Please enter an Administrative MySQL User on the Remote Node: " mysqluser
                read -s -p "Please enter $mysqluser's MySQL Password on the Remote Node: " mysqlpass
                break;;
        * ) echo "Please answer yes or no.";;
    esac
done
#
echo ''
#Get Current Amount of Configured Assets
mysql -h $ipaddr -D'status' --user="$mysqluser" --password="$mysqlpass" -e "SELECT ID FROM cpu;" > dbidnums.txt 2>/dev/null
i=$(awk '/./{line=$0} END{print line}' dbidnums.txt)
#Get All ID Numbers (smallest first, largest last)
cat dbidnums.txt | grep -oP '^[^0-9]*\K[0-9]+' > lastid.txt
#Select last line of file
cat lastid.txt | awk '/./{line=$0} END{print line}' > sclastid.txt
i=$(awk '/./{line=$0} END{print line}' sclastid.txt)
#Le Maths
one="1"
number=$(echo $[$i - $one])
printf "+ ${green} You currently have $number hosts configured${nc}\n"
#Add one to make it acceptable
((number++))
#Remove source
rm lastid.txt sclastid.txt dbidnums.txt
#
echo "Checking if Database & Table exists..."
mysqlshow -h $ipaddr --user="$mysqluser" --password="$mysqlpass" status >> dbfile.txt 2>/dev/null
if grep -q cpu "dbfile.txt"; then
        printf "${green} Table 'status.cpu' exists, continuing...${nc}\n"
fi
if ! grep -q cpu "dbfile.txt"; then
        printf "${red} Table 'status.cpu' Doesn't exist, Installing...${nc}\n"
        mysql -h $ipaddr -D'status' --user="$mysqluser" --password="$mysqlpass" -e "CREATE TABLE IF NOT EXISTS cpu ( id INT AUTO_INCREMENT NOT NULL, hostname VARCHAR(255), loadonemin VARCHAR(10), loadtenmin VARCHAR(10), loadfifmin VARCHAR(10), x VARCHAR(10), y VARCHAR(10), PRIMARY KEY (id));" 2>/dev/null
fi
rm dbfile.txt
echo ''
#
#Begin Constructing Package;
#
constructfile="/root/scripts/SECSUITE/inframon/node-install/load-avg-monitor-$hostname.sh"
echo "#!/bin/bash" >> $constructfile
echo "#Variables" >> $constructfile
echo "mysqlusername='$mysqluser'" >> $constructfile
echo "mysqlpassword='$mysqlpass'" >> $constructfile
echo "workfile='/root/scripts/SECSUITE/inframon/cpufiles/$hostname/workfile.csv'" >> $constructfile
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
#The below option will become available in another method.
# while true; do
#    read -p "Would you like to use this machine as a Processing Server (Default) (Y) or send to a remote site (N)? (y/n): " yn
#    case $yn in
#        [Yy]* ) break;;
#        [Nn]* ) read -p "Please enter the SSH Username of your Processing Server: " procuser ; read -p "Please enter the IP address of your Processing Server: " procsrv ; read -p "Please input the SSH port number of your Processing Server" procsrvport ; echo "rsync -avzh 'ssh -p $procsrvport' /var/lib/mysql-files/importfile.csv $procuser@$procsrv:/root/scripts/SECSUITE/inframon/cpufiles/$hostname/" >> $constructfile ;exit;;
#        * ) echo "Please answer yes or no.";;
#    esac
# done
echo "bash /root/scripts/SECSUITE/inframon/cpufiles/$hostname/cpu-load-monitor.sh" >> $constructfile
echo "exit" >> $constructfile
sed -i 's/$ i/$i/g' $constructfile
sed -i 's/$ 0/$0/g' $constructfile
sed -i 's/$ (awk/$(awk/g' $constructfile
sed -i 's/$ hostname/$hostname/g' $constructfile
sed -i 's/$ importfile/$importfile/g' $constructfile
sed -i 's/$ workfile/$workfile/g' $constructfile
#
printf "+ Your monitor script is available at: ${green} $constructfile ${nc}and will be sent to ${green}$hostname${nc}...\n"
#
echo "Sending monitor..."
rsync -avzh -e "ssh -p $rhostport" $constructfile $sudousr@$ipaddr:/root/scripts/SECSUITE/inframon/cpufiles/$hostname/ --quiet
ssh -p $rhostport $sudousr@$ipaddr chmod 755 /root/scripts/SECSUITE/inframon/cpufiles/$hostname/load-avg-monitor-$hostname.sh
ssh -p $rhostport $sudousr@$ipaddr chmod 755 /root/scripts/SECSUITE/inframon/cpufiles/$hostname/cpu-load-monitor.sh
#
echo ''
#Remove sources
rm $installscript optionfile.txt final-ips.txt nmapfile.txt nmapfiltered.txt sanitised.txt ipaddrfile.txt inetfile.txt netfile.txt
#
#Configure Latency Monitor
#
#Begin
#
printf "${green} ____  _____ ____ ____  _   _ ___ _____ _____${nc}\n"
printf "${green}/ ___|| ____/ ___/ ___|| | | |_ _|_   _| ____|${nc}\n"
printf "${green}\___ \|  _|| |   \___ \| | | || |  | | |  _|${nc}\n"
printf "${green} ___) | |__| |___ ___) | |_| || |  | | | |___${nc}\n"
printf "${green}|____/|_____\____|____/ \___/|___| |_| |_____|${nc}\n"
printf "${green}     REMOTE-LATENCY-MONITOR-INSTALLER${nc}\n"
#
while true; do
    read -p "Do you wish to use $mysqluser as the MySQL user? (y/n): " yn
    case $yn in
        [Yy]* ) echo "Skipping Credential Input."; break;;
        [Nn]* ) echo ""
                read -p "Please enter an Administrative MySQL User on the Remote Node: " mysqluser
                read -s -p "Please enter $mysqluser's MySQL Password on the Remote Node: " mysqlpass
                break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo ''
read -p "Please enter the Web Server Port of the Remote Node: " wsp
echo ''
#
echo "You have entered: "
printf "Hostname: ${green} $hostname ${nc}\n"
printf "IP Address: ${green} $ipaddr ${nc}\n"
printf "Web Server Port: ${green} $wsp ${nc}\n"
printf "SSH Server Port: ${green} $rhostport ${nc}\n"
#
echo ''
#
while true; do
    read -p "Is the above information correct? (y/n): " yn
    case $yn in
        [Yy]* ) echo "Confiuguring..."; break;;
        [Nn]* ) echo "Exiting..." ; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
#
echo ''




while true; do
    read -p "Would you like to use $mysqluser as the User to configure DB on the Remote Node? (y/n): " yn
    case $yn in
        [Yy]* ) echo "Skipping Credential Input."; break;;
        [Nn]* ) echo ""
                read -p "Please enter an Administrative Remote MySQL User on the Remote Node: " mysqluser
                read -s -p "Password: " mysqlpass
                break;;
        * ) echo "Please answer yes or no.";;
    esac
done
#
echo "Checking if Latency Database & Table exists..."
mysqlshow -h $ipaddr --user="$mysqluser" --password="$mysqlpass" status >> dbfile.txt # 2>/dev/null
if grep -q srv "dbfile.txt"; then
        printf "${green} Table 'status.srv' exists, continuing...${nc}\n"
fi
if ! grep -q srv "dbfile.txt"; then
        printf "${red} Table 'status.srv' Doesn't exist, Installing...${nc}\n"
        mysql -h $ipaddr -D'status' --user="$mysqluser" --password="$mysqlpass" -e "CREATE TABLE IF NOT EXISTS srv ( id INT AUTO_INCREMENT NOT NULL, hostname VARCHAR(255), lastping VARCHAR(50), PRIMARY KEY (id));" 2>/dev/null
        if grep -q srv "dbfile.txt"; then
        printf "${green} Table 'status.srv' exists, continuing...${nc}\n"
        fi
fi
rm dbfile.txt
#
#START Database Configuration
echo "Configuring Database for new entry..."
#Get the ID numbers from the current database, add one, and use that as the ID for the new one.
mysql -h $ipaddr -D status --user="$mysqluser" --password="$mysqlpass" -e "SELECT ID FROM srv;" > dbidnums.txt 2>/dev/null
i=$(awk '/./{line=$0} END{print line}' dbidnums.txt)
#Add one to make it acceptable
((i++))
#Import Web Server
mysql -h $ipaddr -D status --user="$mysqluser" --password="$mysqlpass" -e "INSERT INTO srv (id, hostname, lastping) VALUES ('$i','$hostname Web Server','Awaiting Configuration');" 2>/dev/null
#Check
echo "Web Server Inserted with ID Number $i: "
mysql -h $ipaddr -D status --user="$mysqluser" --password="$mysqlpass" -e "SELECT * FROM srv WHERE id = '$i';" 2>/dev/null
#Add another for the SSH Server
((i++))
#Import
mysql -h $ipaddr -D status --user="$mysqluser" --password="$mysqlpass" -e "INSERT INTO srv (id, hostname, lastping) VALUES ('$i','$hostname SSH Server','Awaiting Configuration');" 2>/dev/null
#Check
echo "SSH Server Inserted with ID Number $i: "
mysql -h $ipaddr -D status --user="$mysqluser" --password="$mysqlpass" -e "SELECT * FROM srv WHERE id = '$i';" 2>/dev/null
#Remove source
rm dbidnums.txt
#START Script Configuration
echo "Configuring Script for new entry..."
#Get Current Amount of Configured Assets
mysql -h $ipaddr -D status --user="$mysqluser" --password="$mysqlpass" -e "SELECT ID FROM srv;" > dbidnums.txt 2>/dev/null
i=$(awk '/./{line=$0} END{print line}' dbidnums.txt)
#
#Get All ID Numbers (smallest first, largest last)
cat dbidnums.txt | grep -oP '^[^0-9]*\K[0-9]+' > lastid.txt
#
#Select last line of file
cat lastid.txt | awk '/./{line=$0} END{print line}' > sclastid.txt
i=$(awk '/./{line=$0} END{print line}' sclastid.txt)
#
two="2"
number=$(echo $[$i - $two])
#Add one to make it acceptable
((number++))
#echo "Web Server ID: " $number
#Add another for SS
((number++))
#echo "SSH Server ID: " $number
#Remove source
rm lastid.txt sclastid.txt dbidnums.txt
#
#Perform maths, for reasons
#Web Maths:
two="2"
filenum=$(echo $[$i - $two])
filenumname="file$filenum='"
((filenum ++))
#Build file name
webfilename=$(echo "file$filenum='/root/scripts/SECSUITE/inframon/tempfiles/file$filenum.csv'")
#Import Web
mysql -h $ipaddr -D status --user="$mysqluser" --password="$mysqlpass" -e "INSERT INTO srv (id, hostname, lastping) VALUES ('$filenum','$hostname Web Server','Awaiting Configuration');" 2>/dev/null
#
#SSH Maths:
one="1"
filenumssh=$(echo $[$i - $one])
filenumnamessh="file$filenumssh='"
((filenumssh ++))
#Build file name
sshfilename=$(echo "file$filenumssh='/root/scripts/SECSUITE/inframon/tempfiles/file$filenumssh.csv'")
#Import SSH
mysql -h $ipaddr -D status --user="$mysqluser" --password="$mysqlpass" -e "INSERT INTO srv (id, hostname, lastping) VALUES ('$filenumssh','$hostname SSH Server','Awaiting Configuration');" 2>/dev/null
#
while true; do
    read -p "Would you like to use $mysqluser as the User for the monitor on the Remote Node? (y/n): " yn
    case $yn in
        [Yy]* ) echo "Skipping Credential Input."; break;;
        [Nn]* ) echo ""
                read -p "Please enter an Administrative MySQL User on the Remote Node: " mysqluser
                read -s -p "Password: " mysqlpass
                break;;
        * ) echo "Please answer yes or no.";;
    esac
done
#
#START Script Creation
#Define Variables for passing;
buildfile="/root/scripts/SECSUITE/inframon/node-install/$hostname-latency-monitor.sh"
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
echo "file01='/root/scripts/SECSUITE/inframon/tempfiles/01.csv'" >> $buildfile
echo "file02='/root/scripts/SECSUITE/inframon/tempfiles/02.csv'" >> $buildfile
echo "#" >> $buildfile
echo "# << BEGIN HOSTS >>" >> $buildfile
echo "#" >> $buildfile
#START Host Web Server
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
echo "mysql --user=$ user --password=$ pass -e " >> qry1.txt
echo '"' >> qry1.txt
echo "use status;update srv set lastping = '$ lastping01' where id='$filenum';" >> qry1.txt
echo '"' >> qry1.txt
echo " 2>/dev/null ; " >> qry1.txt
tr -d '\n' < qry1.txt >> $buildfile
rm qry1.txt
echo "else" >> $buildfile
echo "  nmap $ hostdev -p$wsp > $ file01" >> $buildfile
echo "  lastping01=$ (cat $ file01 | grep 'latency')" >> $buildfile
echo "  mysql --user=$ user --password=$ pass -e " >> qry2.txt
echo '"' >> qry2.txt
echo "use status;update srv set lastping = '$ lastping01' where id='$filenum';" >> qry2.txt
echo '"' >> qry2.txt
echo " 2>/dev/null ; " >> qry2.txt
tr -d '\n' < qry2.txt >> $buildfile
rm qry2.txt
echo "fi" >> $buildfile
echo "#EOF" >> $buildfile
echo "#'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'" >> $buildfile
#START Processing
sed -i 's/$ user/$user/g' $buildfile
sed -i 's/$ pass/$pass/g' $buildfile
sed -i 's/$ (cat/$(cat/g' $buildfile
sed -i 's/SUCCESS= $ ?/SUCCESS=$?/g' $buildfile
sed -i 's/$ file01/$file01/g' $buildfile
sed -i 's/$ hostdev/$hostdev/g' $buildfile
sed -i 's/$ lastping01/$lastping01/g' $buildfile
#START Host SSH Server
((i++))
echo "#'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'" >> $buildfile
echo "#" >> $buildfile
echo "#Host: $hostname (SSH Server)" >> $buildfile
echo "#" >> $buildfile
echo "sleep 1" >> $buildfile
echo "hostdev=$ipaddr" >> $buildfile
echo "nmap $ hostdev -p$rhostport 1>/dev/null 2>/dev/null" >> $buildfile
echo "SUCCESS= $ ?" >> $buildfile
echo "if [ $ SUCCESS -eq 0 ]" >> $buildfile
echo "then" >> $buildfile
echo "  nmap $ hostdev -p$rhostport > $ file02" >> $buildfile
echo "  lastping02=$ (cat $ file02 | grep 'latency')" >> $buildfile
echo "mysql --user=$ user --password=$ pass -e " >> qry1.txt
echo '"' >> qry1.txt
echo "use status;update srv set lastping = '$ lastping02' where id='$filenumssh';" >> qry1.txt
echo '"' >> qry1.txt
echo " 2>/dev/null ; " >> qry1.txt
tr -d '\n' < qry1.txt >> $buildfile
rm qry1.txt
echo "else" >> $buildfile
echo "  nmap $ hostdev -p$rhostport > $ file02" >> $buildfile
echo "  lastping02=$ (cat $ file02 | grep 'latency')" >> $buildfile
echo "  mysql --user=$ user --password=$ pass -e " >> qry2.txt
echo '"' >> qry2.txt
echo "use status;update srv set lastping = '$ lastping02' where id='$filenumssh';" >> qry2.txt
echo '"' >> qry2.txt
echo " 2>/dev/null ; " >> qry2.txt
tr -d '\n' < qry2.txt >> $buildfile
rm qry2.txt
echo "fi" >> $buildfile
echo 'mysql --user=$ user --password=$ pass -e "USE status;INSERT INTO hist_srv (id, hostname, lastping, random, importtime) SELECT *, RAND(), CURRENT_TIMESTAMP() FROM srv;" 2>/dev/null' >> $buildfile
echo "rm $ file01 $ file02" >> $buildfile
echo "#'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'" >> $buildfile
#START Processing
sed -i 's/$ user/$user/g' $buildfile
sed -i 's/$ pass/$pass/g' $buildfile
sed -i 's/$ (cat/$(cat/g' $buildfile
sed -i 's/SUCCESS= $ ?/SUCCESS=$?/g' $buildfile
sed -i 's/$ SUCCESS/$SUCCESS/g' $buildfile
sed -i 's/$ file01/$file01/g' $buildfile
sed -i 's/$ file02/$file02/g' $buildfile
sed -i 's/$ hostdev/$hostdev/g' $buildfile
sed -i 's/$ lastping02/$lastping02/g' $buildfile
#START Verifications
echo ''
echo "Your current hosts: "
mysql -h $ipaddr -D status --user="$mysqluser" --password="$mysqlpass" -e "SELECT * FROM srv;" 2>/dev/null
echo ''
echo "Your network monitor script for $hostname: "
rsync -avzh -e "ssh -p $rhostport" $buildfile $sudousr@$ipaddr:/root/scripts/SECSUITE/inframon/latency-files/ --quiet
ssh -p $rhostport $sudousr@$ipaddr "ls /root/scripts/SECSUITE/inframon/latency-files/$hostname-latency-monitor.sh" >> latencymonitorcheck.txt
#
if grep -q /root/scripts/SECSUITE/inframon/latency-files/$hostname-latency-monitor.sh "latencymonitorcheck.txt"; then
    printf "+ ${green} $FILE ${nc} has been created successfully.\n"
    ssh -p $rhostport $sudousr@$ipaddr chmod 755 /root/scripts/SECSUITE/inframon/latency-files/$hostname-latency-monitor.sh
    rm latencymonitorcheck.txt
  else
    printf "+ ${red} $hostname-latency-monitor.sh ${nc}has not been created! ${red}(X)${nc}\n"
    rm latencymonitorcheck.txt
fi
#
#Configure CPU Temperatures
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
while true; do
    read -p "Is ${menu[$option]} a Virtual Machine? (y/n): " yn
    case $yn in
        [Yy]* ) echo "Unfortunately, we are unable to process Temperature Monitoring on Virtual Environments at this time. The monitor will self-exit if errors appear, and data will not be readable."; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Do you wish to use $mysqluser as the MySQL user? (y/n): " yn
    case $yn in
        [Yy]* ) echo "Skipping Credential Input."; break;;
        [Nn]* ) echo ""
                read -p "Please enter an Administrative MySQL User on the Remote Node: " mysqluser
                read -s -p "Please enter $mysqluser's MySQL Password on the Remote Node: " mysqlpass
                break;;
        * ) echo "Please answer yes or no.";;
    esac
done
temptemplate="/root/scripts/SECSUITE/inframon/temperaturefiles/temperature-monitor.txt"
sed -i "s/mysqluser='MYMYSQLUSR'/mysqluser='$mysqluser'/g" $temptemplate
sed -i "s/mysqlpass='MYMYSQLPASS'/mysqlpass='$mysqlpass'/g" $temptemplate
sed -i "s/hostname='hostname'/hostname='$hostname'/g" $temptemplate
rsync -avzh -e "ssh -p $rhostport" $temptemplate $sudousr@$ipaddr:/root/scripts/SECSUITE/inframon/temperaturefiles/ --quiet
rsync -avzh -e "ssh -p $rhostport" /root/scripts/SECSUITE/inframon/temperaturefiles/resources/sc.txt $sudousr@$ipaddr:/root/scripts/SECSUITE/inframon/temperaturefiles/resources/ --quiet
ssh -p $rhostport $sudousr@$ipaddr mv /root/scripts/SECSUITE/inframon/temperaturefiles/temperature-monitor.txt /root/scripts/SECSUITE/inframon/temperaturefiles/$hostname-temp-monitor.sh
ssh -p $rhostport $sudousr@$ipaddr chmod 755 /root/scripts/SECSUITE/inframon/temperaturefiles/$hostname-temp-monitor.sh
ssh -p $rhostport $sudousr@$ipaddr "ls /root/scripts/SECSUITE/inframon/temperaturefiles/$hostname-temp-monitor.sh" >> tempmonitorcheck.txt
#
sed -i "s/mysqluser='$mysqluser'/mysqluser='MYMYSQLUSR'/g" $temptemplate
sed -i "s/mysqlpass='$mysqlpass'/mysqlpass='MYMYSQLPASS'/g" $temptemplate
sed -i "s/hostname='$hostname'/hostname='hostname'/g" $temptemplate
#
if grep -q /root/scripts/SECSUITE/inframon/temperaturefiles/$hostname-temp-monitor.sh "tempmonitorcheck.txt"; then
    printf "+ ${green} $hostname-temp-monitor.sh${nc} has been created successfully.\n"
    ssh -p $rhostport $sudousr@$ipaddr chmod 755 /root/scripts/SECSUITE/inframon/temperaturefiles/$hostname-temp-monitor.sh
  else
    printf "+ ${red} $hostname-latency-monitor.sh ${nc}has not been created! ${red}(X)${nc}\n"
fi
rm tempmonitorcheck.txt


#Configure Users Monitor
#
#Begin
#
printf "${green} ____  _____ ____ ____  _   _ ___ _____ _____${nc}\n"
printf "${green}/ ___|| ____/ ___/ ___|| | | |_ _|_   _| ____|${nc}\n"
printf "${green}\___ \|  _|| |   \___ \| | | || |  | | |  _|${nc}\n"
printf "${green} ___) | |__| |___ ___) | |_| || |  | | | |___${nc}\n"
printf "${green}|____/|_____\____|____/ \___/|___| |_| |_____|${nc}\n"
printf "${green}        USERS-MONITOR-INSTALLER${nc}\n"
#
while true; do
    read -p "Do you wish to use $mysqluser as the MySQL user? (y/n): " yn
    case $yn in
        [Yy]* ) echo "Skipping Credential Input."; break;;
        [Nn]* ) echo ""
                read -p "Please enter an Administrative MySQL User on the Remote Node: " mysqluser
                read -s -p "Please enter $mysqluser's MySQL Password on the Remote Node: " mysqlpass
                break;;
        * ) echo "Please answer yes or no.";;
    esac
done

mysqlshow -h $ipaddr --user="$mysqluser" --password="$mysqlpass" status >> dbfile.txt 2>/dev/null
if grep -q loggedusers "dbfile.txt"; then
        printf "${green} Table 'status.loggedusers' exists, continuing...${nc}\n"
        rm dbidnums.txt
fi
if ! grep -q loggedusers "dbfile.txt"; then
        printf "${red} Table 'status.loggedusers' Doesn't exist, Installing...${nc}\n"
        mysql -h $ipaddr -D'status' --user="$mysqluser" --password="$mysqlpass" -e "CREATE TABLE loggedusers (username VARCHAR(255) NOT NULL, pts VARCHAR(20) NOT NULL, date VARCHAR(50) NOT NULL, time VARCHAR(20) NOT NULL, ipaddr VARCHAR(255) NOT NULL, PRIMARY KEY (pts));" 2>/dev/null
        mysqlshow -h"$ipaddr" --user="$mysqluser" --password="$mysqlpass" status >> dbfile2.txt 2>/dev/null
        if grep -q loggedusers "dbfile2.txt"; then
        printf "${green} Table 'status.loggedusers' has been created, continuing...${nc}\n"
        fi
        rm dbfile2.txt
fi
rm dbfile.txt
userstemplate="/root/scripts/SECSUITE/inframon/node-install/users-monitor.template"
sed -i "s/mysqluser='MYMYSQLUSR'/mysqluser='$mysqluser'/g" $userstemplate
sed -i "s/mysqlpass='MYMYSQLPASS'/mysqlpass='$mysqlpass'/g" $userstemplate
rsync -avzh -e "ssh -p $rhostport" $userstemplate $sudousr@$ipaddr:/root/scripts/SECSUITE/inframon/ --quiet
ssh -p $rhostport $sudousr@$ipaddr "mv /root/scripts/SECSUITE/inframon/users-monitor.template /root/scripts/SECSUITE/inframon/users-monitor.sh"
sed -i "s/mysqluser='$mysqluser'/mysqluser='MYMYSQLUSR'/g" $userstemplate
sed -i "s/mysqlpass='$mysqlpass'/mysqlpass='MYMYSQLPASS'/g" $userstemplate

echo ""
#
printf "${green} ____  _____ ____ ____  _   _ ___ _____ _____${nc}\n"
printf "${green}/ ___|| ____/ ___/ ___|| | | |_ _|_   _| ____|${nc}\n"
printf "${green}\___ \|  _|| |   \___ \| | | || |  | | |  _|${nc}\n"
printf "${green} ___) | |__| |___ ___) | |_| || |  | | | |___${nc}\n"
printf "${green}|____/|_____\____|____/ \___/|___| |_| |_____|${nc}\n"
printf "${green}        INSTALLATION COMPLETE!${nc}\n"
#
echo ""

while true; do
    read -p "Do you wish to test the installed components? (Y/n): " yn
    case $yn in
        [Yy]* ) echo "Testing installed components..."
                echo "Executing Apache Monitor, CPU Load Avg Monitor, CPU Temperature Monitor, Latency Monitor & Users Monitor"
                ssh -p $rhostport $sudousr@$ipaddr bash /root/scripts/SECSUITE/inframon/apachestatus/apache-monitor-$hostname.sh
                sleep 2
                ssh -p $rhostport $sudousr@$ipaddr bash /root/scripts/SECSUITE/inframon/cpufiles/$hostname/load-avg-monitor-$hostname.sh
                sleep 2
                ssh -p $rhostport $sudousr@$ipaddr bash /root/scripts/SECSUITE/inframon/latency-files/$hostname-latency-monitor.sh
                sleep 2
                ssh -p $rhostport $sudousr@$ipaddr bash /root/scripts/SECSUITE/inframon/users-monitor.sh
                echo ''
                echo "Retrieving Values..."
                echo ''
                echo "Apache Status:"
                mysql -h"$ipaddr" -D'status' --user="$mysqluser" --password="$mysqlpass" -e "SELECT * FROM apachestatus;" 2>/dev/null
                echo "CPU Load Averages:"
                mysql -h"$ipaddr" -D'status' --user="$mysqluser" --password="$mysqlpass" -e "SELECT * FROM cpu;" 2>/dev/null
                echo "CPU Temperatures:"
                ssh -p $rhostport $sudousr@$ipaddr bash /root/scripts/SECSUITE/inframon/temperaturefiles/$hostname-temp-monitor.sh
                echo "Latency:"
                mysql -h"$ipaddr" -D'status' --user="$mysqluser" --password="$mysqlpass" -e "SELECT * FROM srv;" 2>/dev/null
                echo "Users:"
                mysql -h"$ipaddr" -D'status' --user="$mysqluser" --password="$mysqlpass" -e "SELECT * FROM loggedusers;" 2>/dev/null
                echo ''
                echo "If you would like to actively monitor $hostname, you will need to add the following lines in your crontab file:"
                echo "* * * * * bash /root/scripts/SECSUITE/inframon/apachestatus/apache-monitor-$hostname.sh"
                echo "* * * * * bash /root/scripts/SECSUITE/inframon/cpufiles/$hostname/load-avg-monitor-$hostname.sh"
                echo "* * * * * bash /root/scripts/SECSUITE/inframon/latency-files/$hostname-latency-monitor.sh"
                echo "* * * * * bash /root/scripts/SECSUITE/inframon/temperaturefiles/$hostname-temp-monitor.sh"
                echo "* * * * * bash /root/scripts/SECSUITE/inframon/users-monitor.sh"
                echo ''
                break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
#
exit
