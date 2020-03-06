#!/bin/bash
#
#This script is intended for SECSUITE users to use the Leroy component of SECSUITE.
#Written by Daniel Ward
#Version 1.290120
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
printf "${green}           LEROY-FILE-MANAGER${nc}\n"
echo ''
echo "Welcome to the SECSUITE Leroy File Manager"
echo ''
#
echo "Checking for current servers..."
FILE="/root/scripts/SECSUITE/LEROY/serverlist.conf"
if [ -f "$FILE" ]; then
#
printf "+ ${green}Server list file found${nc}. continuing...\n"
read -p "Please select the file to be backed up (full path (example: '/var/www/html/yoursite/file.html): " backupfile
read -p "Enter directory (full path (example: '/var/www/html/yoursite/')) to backup to (local):  " backuploc
unset option menu ERROR      # prevent inheriting values from the shell
declare -a menu              # create an array called $menu
menu[0]=""                   # set and ignore index zero so we can count from 1
# read menu file line-by-line, save as $line
while IFS= read -r line; do
  menu[${#menu[@]}]="$line"  # push $line onto $menu[]
done < /root/scripts/SECSUITE/LEROY/serverlist.conf
# function to show the menu
menu() {
  echo "Please select a host by typing in the corresponding number"
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
  echo "No such option '$option'" >&2  # output this to standard error
  menu
  read option
done
else
printf "+ ${red}Server list not file found${nc}. Continuing to setup...\n"
echo "To configure your serverlist.conf file, please complete the following information: "
read -p "Please enter the HOSTNAME of the remote host: " rhost
read -p "Please enter the IP or DNS of the remote host: " rhostip
read -p "Please enter the SSH Username of the remote host: " rhostsshuser
while true; do
    read -p "Are you running SSH on port 22? (Y/n): " yn
    case $yn in
        [Yy]* ) echo "$rhost $rhostip 22 $rhostsshuser" break;;
        [Nn]* ) read -p "Please insert the port number: " rhostport ; break;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo "$rhost $rhostip $rhostport $rhostsshuser" >> /root/scripts/SECSUITE/LEROY/serverlist.conf
echo ''
cat /root/scripts/SECSUITE/LEROY/serverlist.conf
echo ''
while true; do
    read -p "Are the above hosts correct? (Y/y) or would you like to edit the file? (E/e): " ye
    case $ye in
        [Yy]* ) break;;
        [Ee]* ) nano /root/scripts/SECSUITE/LEROY/serverlist.conf ; break;;
        * ) echo "Please answer yes or edit.";;
    esac
done
PS3='Please enter your choice: '
options=("-> Continue" "-> Edit Server List" "-> Quit")
select opt in "${options[@]}"
do
    case $opt in
        "-> Continue")
            printf "+ ${green}Continuing${nc}...\n" ; break
            ;;
        "-> Edit Server List")
            nano /root/scripts/SECSUITE/LEROY/serverlist.conf
            ;;
        "-> Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
read -p "Please select the file to be backed up (full path (example: '/var/www/html/yoursite/file.html): " backupfile
read -p "Enter directory (full path (example: '/var/www/html/yoursite/')) to backup to (local):  " backuploc
unset option menu ERROR      # prevent inheriting values from the shell
declare -a menu              # create an array called $menu
menu[0]=""                   # set and ignore index zero so we can count from 1
# read menu file line-by-line, save as $line
while IFS= read -r line; do
  menu[${#menu[@]}]="$line"  # push $line onto $menu[]
done < /root/scripts/SECSUITE/LEROY/serverlist.conf
# function to show the menu
menu() {
  echo "Please select a host by typing in the corresponding number"
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
  echo "No such option '$option'" >&2  # output this to standard error
  menu
  read option
done
fi
echo "You said '$option' which is '${menu[$option]}'"
echo "${menu[$option]}" >> qry1.txt
echo ""
user=$(cat qry1.txt | awk '{print $4}')
ip=$(cat qry1.txt | awk '{print $2}')
rhostport=$(cat qry1.txt | awk '{print $3}')
rsync -avzh -e "ssh -p $rhostport" $user@$ip:$backupfile  $backuploc --quiet
rm /root/scripts/SECSUITE/LEROY/qry1.txt
echo "File has been backed up."
exit
