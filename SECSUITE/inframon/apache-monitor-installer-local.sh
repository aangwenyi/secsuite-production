#!/bin/bash
#
# ____  _____ ____ ____  _   _ ___ _____ _____
#/ ___|| ____/ ___/ ___|| | | |_ _|_   _| ____|
#\___ \|  _|| |   \___ \| | | || |  | | |  _|
# ___) | |__| |___ ___) | |_| || |  | | | |___
#|____/|_____\____|____/ \___/|___| |_| |_____|
#       APACHE-STATUS-INSTALLER
#
#
#Global Variables
#
#MySQL Creds (optional)
mysqluser="user"
mysqlpass="pass"
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
printf "${green}       APACHE-STATUS-INSTALLER${nc}\n"
#
echo ''
echo "Welcome to the SECSUITE Apache Monitor Installer"
echo ''
#
read -p "Please enter the HOSTNAME of your new asset: " hostname
#
while true; do
    read -p "Have you already configured your Apache Status Database Credentials? (y/n): " yn
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
constructfile="/root/scripts/SECSUITE/inframon/apachestatus/apache-monitor-$hostname.sh"
#
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
#
echo "Checking database for entries..."
mysqlshow --user=$mysqluser --password=$mysqlpass status >> dbfile.txt
if grep -q apachestatus "dbfile.txt"; then
        printf "${green} Table 'status.apachestatus' exists, continuing...${nc}\n"
        echo "Getting new ID for $hostname..."
        #Get the ID numbers from the current database, add one, and use that as the ID for the new one.
        mysql --user=$mysqluser --password=$mysqlpass -e "use status;SELECT ID FROM apachestatus;" > dbidnums.txt 2>/dev/null
        i=$(awk '/./{line=$0} END{print line}' dbidnums.txt)
        #Add one to make it acceptable
        ((i++))
        printf "+ The new ID has been generated: ${green} $i ${nc}\n"
fi
if ! grep -q apachestatus "dbfile.txt"; then
        printf "${red} Table 'status.apachestatus' Doesn't exist, Installing...${nc}\n"
        mysql --user=$mysqluser --password=$mysqlpass -e "USE status;CREATE TABLE apachestatus (id INT AUTO_INCREMENT NOT NULL, hostname VARCHAR(255) NOT NULL, apachestatus VARCHAR(255) NOT NULL, PRIMARY KEY (id));" 2>/dev/null
fi
rm dbfile.txt dbidnums.txt
#
echo 'if grep -q "active (running)" "$ statusfile"; then' >> $constructfile
echo 'cat $ statusfile | grep -E "Active" > $ statusfile1' >> $constructfile
echo 'mysql --user=$ mysqluser --password=$ mysqlpass -e "use status;truncate table apachestatus;" 2>/dev/null' >> $constructfile
echo "sed -i '1 i\ $i, $hostname,' $ statusfile1" >> $constructfile
echo 'tr -d "\n\r" < $ statusfile1 > /var/lib/mysql-files/importapachestatus.csv' >> $constructfile
echo 'mysql --user=$ mysqluser --password=$ mysqlpass -e "USE status;LOAD DATA INFILE ' >> qry1.txt
echo "'/var/lib/mysql-files/importapachestatus.csv' INTO TABLE apachestatus FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';" >> qry1.txt
echo '" 2>/dev/null' >> qry1.txt
tr -d '\n' < qry1.txt > qry2.txt
cat qry2.txt >> $constructfile
rm qry1.txt qry2.txt
echo "" >> $constructfile
echo 'fi' >> $constructfile
#
echo 'if grep -q "inactive (dead)" "$ statusfile"; then' >> $constructfile
echo 'echo "Apache Server is Offline!" >> $ statusfile1' >> $constructfile
echo 'mysql --user=$ mysqluser --password=$ mysqlpass -e "use status;truncate table apachestatus;" 2>/dev/null' >> $constructfile
echo "sed -i '1 i\ $i, $hostname,' $ statusfile1" >> $constructfile
echo 'tr -d "\n\r" < $ statusfile1 > /var/lib/mysql-files/importapachestatus.csv' >> $constructfile
echo 'mysql --user=$ mysqluser --password=$ mysqlpass -e "USE status;LOAD DATA INFILE ' >> qry1.txt
echo "'/var/lib/mysql-files/importapachestatus.csv' INTO TABLE apachestatus FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';" >> qry1.txt
echo '" 2>/dev/null' >> qry1.txt
tr -d '\n' < qry1.txt > qry2.txt
cat qry2.txt >> $constructfile
rm qry1.txt qry2.txt
echo "" >> $constructfile
echo 'fi' >> $constructfile
#
echo 'mysql --user=$ mysqluser --password=$ mysqlpass -e "use status;INSERT INTO hist_apachestatus SELECT *, CURRENT_TIMESTAMP() FROM apachestatus;" 2>/dev/null' >> $constructfile
echo "rm $ statusfile $ statusfile2 $ statusfile1 $ statusfilenonl" >> $constructfile
#
sed -i 's/$ mysqluser/$mysqluser/g' $constructfile
sed -i 's/$ mysqlpass/$mysqlpass/g' $constructfile
sed -i 's/$ statusfile/$statusfile/g' $constructfile
sed -i 's/$ statusfile2/$statusfile2/g' $constructfile
sed -i 's/$ statusfile1/$statusfile1/g' $constructfile
sed -i 's/$ statusfilemon1/$statusfilemon1/g' $constructfile
exit
