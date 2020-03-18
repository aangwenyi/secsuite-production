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

if [ -d "/root/scripts/SECSUITE/inframon/apachestatus/" ]; then
        printf " -> /root/scripts/SECSUITE/inframon/apachestatus/ ${green}✓${nc}\n"
    else
        printf " -> /root/scripts/SECSUITE/inframon/apachestatus/ ${red}X${nc}\n"
        printf "+ Creating /root/scripts/SECSUITE/inframon/apachestatus/ (base directory)\n"
        mkdir /root/scripts/SECSUITE/inframon/apachestatus/
        if [ -d "/root/scripts/SECSUITE/inframon/apachestatus/" ]; then
                printf " -> /root/scripts/SECSUITE/inframon/apachestatus/ ${green}✓${nc}\n"
        fi
fi

if [ -d "/root/scripts/SECSUITE/inframon/tempfiles/" ]; then
        printf " -> /root/scripts/SECSUITE/inframon/tempfiles/ ${green}✓${nc}\n"
    else
        printf " -> /root/scripts/SECSUITE/inframon/tempfiles/ ${red}X${nc}\n"
        printf "+ Creating /root/scripts/SECSUITE/inframon/tempfiles/ (base directory)\n"
        mkdir /root/scripts/SECSUITE/inframon/tempfiles/
        if [ -d "/root/scripts/SECSUITE/inframon/tempfiles/" ]; then
                printf " -> /root/scripts/SECSUITE/inframon/tempfiles/ ${green}✓${nc}\n"
        fi
fi

if [ -d "/root/scripts/SECSUITE/inframon/temperaturefiles/" ]; then
        printf " -> /root/scripts/SECSUITE/inframon/temperaturefiles/ ${green}✓${nc}\n"
    else
        printf " -> /root/scripts/SECSUITE/inframon/temperaturefiles/ ${red}X${nc}\n"
        printf "+ Creating /root/scripts/SECSUITE/inframon/temperaturefiles/ (base directory)\n"
        mkdir /root/scripts/SECSUITE/inframon/temperaturefiles/
        if [ -d "/root/scripts/SECSUITE/inframon/temperaturefiles/" ]; then
                printf " -> /root/scripts/SECSUITE/inframon/temperaturefiles/ ${green}✓${nc}\n"
        fi
fi

if [ -d "/root/scripts/SECSUITE/inframon/latency-files/" ]; then
        printf " -> /root/scripts/SECSUITE/inframon/latency-files/ ${green}✓${nc}\n"
    else
        printf " -> /root/scripts/SECSUITE/inframon/latency-files/ ${red}X${nc}\n"
        printf "+ Creating /root/scripts/SECSUITE/inframon/latency-files/ (base directory)\n"
        mkdir /root/scripts/SECSUITE/inframon/latency-files/
        if [ -d "/root/scripts/SECSUITE/inframon/latency-files/" ]; then
                printf " -> /root/scripts/SECSUITE/inframon/latency-files/ ${green}✓${nc}\n"
        fi
fi


if [ -d "/root/scripts/SECSUITE/inframon/cpufiles/" ]; then
        printf " -> /root/scripts/SECSUITE/inframon/cpufiles/ ${green}✓${nc}\n"
    else
        printf " -> /root/scripts/SECSUITE/inframon/cpufiles/ ${red}X${nc}\n"
        printf "+ Creating /root/scripts/SECSUITE/inframon/cpufiles/inframon/cpufiles/ (base directory)\n"
        mkdir /root/scripts/SECSUITE/inframon/cpufiles/
        if [ -d "/root/scripts/SECSUITE/inframon/cpufiles/" ]; then
                printf " -> /root/scripts/SECSUITE/inframon/cpufiles/ ${green}✓${nc}\n"
        fi
fi

rm -rf SECSUITE/
rm -rf ../secsuite-production/

exit
