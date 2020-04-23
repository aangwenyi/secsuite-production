#!/bin/bash
#
basedir="/root/scripts/SECSUITE/inframon"
scriptdir="/root/scripts/SECSUITE/inframon/diskusage"
#
rawfile="$basedir/rawdiskusage.txt"
nclines="$basedir/diskusage.txt"
dbf="$basedir/dbfile.csv"
dbf1="$basedir/dbfile1.csv"
optionfile="$basedir/optionfile.txt"
diskfile="$basedir/diskfile.txt"
script="$scriptdir/disk-monitor-local-probe.sh"
monitorfile="$scriptdir/drives.conf"
qry1="$basedir/qry1.txt"
qry2="$basedir/qry2.txt"
#
#ASCII Colours
red='\033[0;31m'
green='\033[0;32m'
nc='\033[0m'
#
#MySQL Creds (optional)
mysqluser="user"
mysqlpass="pass"
#
printf "${green} ____  _____ ____ ____  _   _ ___ _____ _____${nc}\n"
printf "${green}/ ___|| ____/ ___/ ___|| | | |_ _|_   _| ____|${nc}\n"
printf "${green}\___ \|  _|| |   \___ \| | | || |  | | |  _|${nc}\n"
printf "${green} ___) | |__| |___ ___) | |_| || |  | | | |___${nc}\n"
printf "${green}|____/|_____\____|____/ \___/|___| |_| |_____|${nc}\n"
printf "${green}       	   STORAGE-STATUS-INSTALLER${nc}\n"
#
echo ''
while true; do
    read -p "Have you already configured your Database Credentials? (y/n): " yn
    case $yn in
        [Yy]* ) echo "Skipping this step." ; echo '' ; break;;
        [Nn]* ) echo ""
                read -p "Please enter the MySQL User: " mysqluser
                read -s -p "$mysqluser's Password: " mysqlpass ; echo ""
                break;;
        * ) echo "Please answer yes or no.";;
    esac
done
#
#Database Checks;
mysqlshow --user=$mysqluser --password=$mysqlpass status >> $dbf 2>/dev/null
if grep -q "storagestatus" "$dbf"; then
        printf "${green} Table 'status.storagestatus' Exists, continuing...${nc}\n"
fi
#
if ! grep -q "storagestatus" "$dbf"; then
        printf "${red} Table 'status.storagestatus' Doesn't exist, installing...${nc}\n"
	mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status; CREATE TABLE IF NOT EXISTS storagestatus (id INT AUTO_INCREMENT NOT NULL, hostname VARCHAR(255), filesystem VARCHAR(255), totalsize VARCHAR(255), totalused VARCHAR(255), availablesize VARCHAR(255), usedpercentage VARCHAR(255), mountlocation VARCHAR(255), PRIMARY KEY (id));" 2>/dev/null
	mysqlshow --user=$mysqluser --password=$mysqlpass status >> $dbf1 2>/dev/null
	if grep -q "storagestatus" "$dbf1"; then
	        printf "${green} Table 'status.storagestatus' Has been created, continuing...${nc}\n"
	fi
	rm $dbf1
fi
rm $dbf

#Historical table checks;
mysqlshow --user=$mysqluser --password=$mysqlpass status >> $dbf 2>/dev/null
if grep -q "hist_storagestatus" "$dbf"; then
        printf "${green} Table 'status.hist_storagestatus' Exists, continuing...${nc}\n"
fi
#
if ! grep -q "hist_storagestatus" "$dbf"; then
        printf "${red} Table 'status.hist_storagestatus' Doesn't exist, installing...${nc}\n"
	mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status; CREATE TABLE IF NOT EXISTS hist_storagestatus (id INT AUTO_INCREMENT NOT NULL, hostname VARCHAR(255), filesystem VARCHAR(255), totalsize VARCHAR(255), totalused VARCHAR(255), availablesize VARCHAR(255), usedpercentage VARCHAR(255), mountlocation VARCHAR(255), timestamp VARCHAR(255) NOT NULL, PRIMARY KEY (id));" 2>/dev/null
	mysqlshow --user=$mysqluser --password=$mysqlpass status >> $dbf1 2>/dev/null
	if grep -q "hist_storagestatus" "$dbf1"; then
	        printf "${green} Table 'status.hist_storagestatus' Has been created, continuing...${nc}\n"
	fi
	rm $dbf1
fi
rm $dbf


#
#Print all disk usages to file (standard output)
df -h > $rawfile
#
#Format file for menu
sed -i 's/	/ \,/g' $rawfile
sed -i 's/Use\%/Use_\%/g' $rawfile
sed -i 's/Mounted/Mount_Location/g' $rawfile
#Build list of options
cat $rawfile | awk '{print $1 "	, (MountedOn: "$6" )"}' > $optionfile
#
newdisk=$(cat $optionfile | awk '{print $1}')
#
#Get specific disk or partition(s)
unset option menu ERROR      # prevent inheriting values from the shell
declare -a menu              # create an array called $menu
menu[0]=""                   # set and ignore index zero so we can count from 1
# read menu file line-by-line, save as $line
while IFS= read -r line; do
  menu[${#menu[@]}]="$line"  # push $line onto $menu[]
done < $optionfile
# function to show the menu
menu() {
  echo ""
  echo "Select a disk or partition by typing in the corresponding ID number: "
  echo ""
  echo ""
  for (( i=1; i<${#menu[@]}; i++ )); do
    echo "$i) ${menu[$i]}"
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
if grep -q "${menu[$option]}" "$diskfile" 2>/dev/null; then
  echo ''
  echo "This disk is already being monitored." ; exit
  else
  echo ''
  echo "Adding option '$option' to actively monitored disks..."
  echo "${menu[$option]}" >> $diskfile
  newdisk=$(cat $diskfile | awk '{print $1}')
fi
read -p "Please introduce a new HOSTNAME for the disk '$newdisk': " hostname
echo ""
#
output=$(echo "$hostname" ; echo "," ; cat $diskfile | awk '{print $1 " " $2 " " $4}')
cat $diskfile | awk '{print $1}' >> $monitorfile
#echo $output
echo ''
#
#If script is existing:
if grep -q "#!/bin/bash" "$script" 2>/dev/null; then
echo "Script already exists. Nothing to create."
fi
#If not existing:
if ! grep -q "#!/bin/bash" "$script" 2>/dev/null; then
echo "#!/bin/bash" >> $script
echo "basedir='/root/scripts/SECSUITE/inframon/diskusage'" >> $script
echo 'input="$basedir/drives.conf"' >> $script
echo 'importfile="/var/lib/mysql-files/diskusageimport.csv"' >> $script
echo 'uniquedrives=$(cat $ input | uniq)' >> $script
echo 'dffile="$basedir/dffile.txt"' >> $script
echo 'monitoredfile="$basedir/monitoredfile.txt"' >> $script
echo "hostname=$hostname" >> $script
echo '#' >> $script
echo "#MySQL Creds;" >> $script
echo "mysqluser='$mysqluser'" >> $script
echo "mysqlpass='$mysqlpass'" >> $script
echo '#' >> $script
echo 'df -h > $dffile' >> $script
echo "" >> $script
echo "while IFS= read -r line" >> $script
echo "do" >> $script
echo 'if grep -q "$line" "$monitoredfile" 2>/dev/null; then' >> $script
# echo 'cat $dffile | grep -E "$uniquedrives"' >> $script
echo 'rm $dffile' >> $script
echo 'exit' >> $script
echo 'fi' >> $script
echo 'if ! grep -q "$line" "$monitoredfile" 2>/dev/null; then' >> $script
echo ' cat $dffile | grep -E "$line" > $monitoredfile' >> $script
echo 'sed -i "s/^/ /" $monitoredfile' >> $script
echo 'sed -i "s/^/$ hostname/" $monitoredfile' >> $script
echo 'cat $monitoredfile | uniq | awk ' >> $qry1
echo "'" >> $qry1
echo '{print $1 " , " $2 " , " $3 " , " $4 " , " $5 " , " $6 " , " $7}' >> $qry1
echo "'" >> $qry1
tr -d "\n" < $qry1 > $qry2
echo ' >> $importfile' >> $qry2
cat $qry2 >> $script
echo 'fi' >> $script
echo 'done < "$input"' >> $script
rm $qry1 $qry2
echo 'mysql --user="$ mysqluser" --password="$ mysqlpass" -e "USE status;TRUNCATE TABLE storagestatus;" 2>/dev/null' >> $script
echo 'mysql --user="$ mysqluser" --password="$ mysqlpass" -e "USE status;' >> $qry1
echo "LOAD DATA INFILE '$ importfile' INTO TABLE storagestatus FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' (hostname, filesystem, totalsize, totalused, availablesize, usedpercentage, mountlocation);" >> $qry1
echo '"' >> $qry1
tr -d "\n" < $qry1 > $qry2
echo " 2>/dev/null" >> $qry2
cat $qry2 >> $script
echo 'mysql --user="$ mysqluser" --password="$ mysqlpass" -e "USE status;INSERT INTO hist_storagestatus (hostname, filesystem, totalsize, totalused, availablesize, usedpercentage, mountlocation, timestamp) SELECT hostname, filesystem, totalsize, totalused, availablesize, usedpercentage, mountlocation, CURRENT_TIMESTAMP() FROM storagestatus;" 2>/dev/null' >> $script
echo '' >> $script
echo 'rm $dffile $monitoredfile $importfile' >> $script
sed -i 's/$ input/$input/g' $script
sed -i 's/$ importfile/$importfile/g' $script
sed -i 's/$ hostname/$hostname/g' $script
sed -i 's/$ mysqluser/$mysqluser/g' $script
sed -i 's/$ mysqlpass/$mysqlpass/g' $script
fi
#
echo ""
echo "Script output: "
bash $script
#
echo ""
echo "MySQL Imported Data:"
mysql --user="$mysqluser" --password="$mysqlpass" -e "USE status; SELECT * FROM storagestatus;" 2>/dev/null
#
rm $rawfile $optionfile $diskfile $qry1 $qry2
