#!/bin/bash
#
#ASCII Colours
red='\033[0;31m'
green='\033[0;32m'
nc='\033[0m'
#
basedir="/root/scripts/SECSUITE"
#
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

if [ -d "$basedir/" ]; then
        printf " -> $basedir/ ${green}✓${nc}\n"
    else
        printf " -> $basedir/ ${red}X${nc}\n"
        printf "+ Creating $basedir/ (base directory)\n"
        mkdir $basedir/
        if [ -d "$basedir/" ]; then
                printf " -> $basedir/ ${green}✓${nc}\n"
        fi
fi

mv SECSUITE/* $basedir/
mv README.md $basedir/

if [ -d "$basedir/inframon/apachestatus/" ]; then
        printf " -> $basedir/inframon/apachestatus/ ${green}✓${nc}\n"
    else
        printf " -> $basedir/inframon/apachestatus/ ${red}X${nc}\n"
        printf "+ Creating $basedir/inframon/apachestatus/ (base directory)\n"
        mkdir $basedir/inframon/apachestatus/
        if [ -d "$basedir/inframon/apachestatus/" ]; then
                printf " -> $basedir/inframon/apachestatus/ ${green}✓${nc}\n"
        fi
fi

if [ -d "$basedir/inframon/tempfiles/" ]; then
        printf " -> $basedir/inframon/tempfiles/ ${green}✓${nc}\n"
    else
        printf " -> $basedir/inframon/tempfiles/ ${red}X${nc}\n"
        printf "+ Creating $basedir/inframon/tempfiles/ (base directory)\n"
        mkdir $basedir/inframon/tempfiles/
        if [ -d "$basedir/inframon/tempfiles/" ]; then
                printf " -> $basedir/inframon/tempfiles/ ${green}✓${nc}\n"
        fi
fi

if [ -d "$basedir/inframon/temperaturefiles/" ]; then
        printf " -> $basedir/inframon/temperaturefiles/ ${green}✓${nc}\n"
    else
        printf " -> $basedir/inframon/temperaturefiles/ ${red}X${nc}\n"
        printf "+ Creating $basedir/inframon/temperaturefiles/ (base directory)\n"
        mkdir $basedir/inframon/temperaturefiles/
        if [ -d "$basedir/inframon/temperaturefiles/" ]; then
                printf " -> $basedir/inframon/temperaturefiles/ ${green}✓${nc}\n"
        fi
fi

if [ -d "$basedir/inframon/latency-files/" ]; then
        printf " -> $basedir/inframon/latency-files/ ${green}✓${nc}\n"
    else
        printf " -> $basedir/inframon/latency-files/ ${red}X${nc}\n"
        printf "+ Creating $basedir/inframon/latency-files/ (base directory)\n"
        mkdir $basedir/inframon/latency-files/
        if [ -d "$basedir/inframon/latency-files/" ]; then
                printf " -> $basedir/inframon/latency-files/ ${green}✓${nc}\n"
        fi
fi


if [ -d "$basedir/inframon/cpufiles/" ]; then
        printf " -> $basedir/inframon/cpufiles/ ${green}✓${nc}\n"
    else
        printf " -> $basedir/inframon/cpufiles/ ${red}X${nc}\n"
        printf "+ Creating $basedir/inframon/cpufiles/inframon/cpufiles/ (base directory)\n"
        mkdir $basedir/inframon/cpufiles/
        if [ -d "$basedir/inframon/cpufiles/" ]; then
                printf " -> $basedir/inframon/cpufiles/ ${green}✓${nc}\n"
        fi
fi

rm -rf SECSUITE/
rm -rf ../secsuite-production/

echo ''
printf "${green} Your installation of SECSUITE is available at: $basedir/ ${nc}\n"

exit
