#!/bin/bash
#
#Global Variables
userpass='userpass.txt'
anitised='sanitised.txt'
passbuilder='passbuilder.txt'
#ASCII Colours, for user-friendliness
red='\033[0;31m'
green='\033[0;32m'
nocolor='\033[0m'
nc='\033[0m'
#Begin
#
printf "${green} ____  _____ ____ ____  _   _ ___ _____ _____${nc}\n"
printf "${green}/ ___|| ____/ ___/ ___|| | | |_ _|_   _| ____|${nc}\n"
printf "${green}\___ \|  _|| |   \___ \| | | || |  | | |  _|${nc}\n"
printf "${green} ___) | |__| |___ ___) | |_| || |  | | | |___${nc}\n"
printf "${green}|____/|_____\____|____/ \___/|___| |_| |_____|${nc}\n"
printf "${green}           imgPassAuth Generator${nc}\n"
#
# Get the screenshot
import -window root screenshot.png
convert screenshot.png image.jpg
rm screenshot.png
sha512sum image.jpg > $userpass
cat $userpass | awk '{print $1}' > $anitised
cat $anitised >> $passbuilder
cat $anitised >> $passbuilder
echo ''
output=$(ls /home/)
printf "${green}$output${nocolor}\n\n"
read -p "Please specify the username from the options above: " useracc
echo ''
cat $passbuilder | passwd $useracc
echo ''
finalpass=$(cat $anitised)
printf "${green}New password is:  ${nocolor}" ; printf "${red}$finalpass${nocolor}\n\n"
rm *.txt*
mv image.jpg image-on-$(date "+%Y.%m.%d-%H.%M.%S").jpg
exit
