#!/bin/bash
# Load Variables;
# Files
logsrc='/var/log/auth.log'
tempdir="/root/scripts/SECSUITE/logblocker/temp"
procfile='$tempdir/procfile.txt'
procfile1='$tempdir/procfile1.txt'
procfile2='$tempdir/procfile2.txt'
procfile3='$tempdir/procfile3.txt'
procfile4='$tempdir/procfile4.txt'
procfile5='$tempdir/procfile5.txt'
#ASCII Colours
red='\033[0;31m'
green='\033[0;32m'
nc='\033[0m'
lightgreen='\033[1;32m'
lightpurple='\033[1;35m'
#
#
printf "${green} _             _     _            _ ${nc}\n"
printf "${green}| | ___   __ _| |__ | | ___   ___| | _____ _ __ ${nc}\n"
printf "${green}| |/ _ \ / _  | '_ \| |/ _ \ / __| |/ / _ \ '__| ${nc}\n"
printf "${green}| | (_) | (_| | |_) | | (_) | (__|   <  __/ | ${nc}\n"
printf "${green}|_|\___/ \__, |_.__/|_|\___/ \___|_|\_\___|_| ${nc}\n"
printf "${green}         |___/ ${nc}\n"
#
#
#Directory check
echo "Directory Checks..."
dir0="/root/scripts/SECSUITE/logblocker/temp/"
if [ -d "$dir0" ]; then
        printf " -> $dir0 ${green}✓${nc}\n"
    else
        printf " -> $dir0 ${red}X${nc}\n"
        printf "+ Creating $dir0 (base directory)\n"
        mkdir $dir0
        if [ -d "$dir0" ]; then
        printf " -> $dir0 ${green}✓${nc}\n"
        fi
fi
echo ""
# Do the thing;
echo "Gathering true attackers (wrong users and root attempts)..."
cat $logsrc | grep -E "Invalid user" >> $procfile
cat $logsrc | grep -E "maximum authentication attempts exceeded for root" >> $procfile
echo "Getting IPs into our processing file..."
# Get count of IP addresses in file
cat $procfile | grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' | awk '{print $0}' >> $procfile1
if [ ! -f "$procfile1" ]
then
        printf "+  ${red} ERROR! Something failed!${nc}\n\n"
        echo "exiting"
        exit
fi
        printf "+  IP file created: ${lightgreen}OK${nc}\n\n"
#
echo "Counting your attackers per IP..."
uniq -c $procfile1 | awk '{print $2": "$1}' >> $procfile2
if [ ! -f "$procfile" ]
then
        printf "+  ${red} ERROR! Something failed!${nc}\n\n"
        echo "exiting"
        exit
fi
        printf "+  Unique Attacker file created: ${lightgreen}$(cat $procfile1 | wc -l) Unique Attackers Found${nc}\n\n"
#
echo "Getting attackers who have tried >= 5 times..."
# Create a threshold of 5 attempts per attacker
awk ' $2 >= 5 ' $procfile2 > $procfile3
if [ ! -f "$procfile2" ]
then
        printf "+  ${red} ERROR! Something failed!${nc}\n\n"
        echo "exiting"
        exit
fi
        printf "+  Serial Attacker file created: ${lightgreen}$(cat $procfile2 | wc -l) Unique Serial Attackers Found${nc}\n\n"
#
_file="$procfile1"
[ ! -f "$_file" ] && { echo "Error: $procfile1 file not found."; exit 2; }
if [ -s "$_file" ]
then
echo "Sharpening the blade..."
cat $procfile3 | awk '{print "ufw deny from",$1,"to any"}' > $procfile4
#
sed -i 's/: to/ to/g' $procfile4
#
echo "Displaying top 10 lines of blockfile..."
cat $procfile4 | uniq >> $procfile5
tail -10 $procfile5
#
#Just ban them:
bash $procfile5
else
printf "+ ${lightgreen}No Attackers Found, Neo.${nc}\nExiting.\n"
fi
echo "Removing source files..."
rm -rf $procfile $procfile1 $procfile2 $procfile3 $procfile4
exit
