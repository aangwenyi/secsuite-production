#!/bin/bash
#
#ASCII Colours
red='\033[0;31m'
green='\033[0;32m'
nc='\033[0m'
#Preconfigure directory structure for SECSUITE
#
if [ -d "/root/scripts/" ]; then
	printf " -> /root/scripts/ ${green}✓${nc}\n"
    else
	printf " -> /root/scripts/ ${red}X${nc}\n"
	printf "+ Creating /root/scripts/ (base directory)\n"
	mkdir /root/scripts/
	if [ -d "/root/scripts/" ]; then
		printf " -> /root/scripts/ ${green}✓${nc}\n"
	fi
fi

if [ -d "/root/scripts/SECSUITE/" ]; then
        printf " -> /root/scripts/SECSUITE/ ${green}✓${nc}\n"
    else
        printf " -> /root/scripts/SECSUITE/ ${red}X${nc}\n"
        printf "+ Creating /root/scripts/SECSUITE/ (base directory)\n"
        mkdir /root/scripts/SECSUITE/
        if [ -d "/root/scripts/SECSUITE/" ]; then
                printf " -> /root/scripts/SECSUITE/ ${green}✓${nc}\n"
        fi
fi

mv SECSUITE/* /root/scripts/SECSUITE/
mv README.md /root/scripts/SECSUITE/
rm -rf SECSUITE/
rm -rf ../secsuite-production/
exit
