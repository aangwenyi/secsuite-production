#!/bin/bash

export TERM=xterm

which dialog > dialogcheck.txt
if grep -q dialog "dialogcheck.txt"; then
  rm dialogcheck.txt
  else
  printf "+ ${red}Installing Dialog${nc}...\n"
  apt-get install dialog -y -qq > /dev/null
  rm dialogcheck.txt
    which dialog > dialogcheck.txt
    if grep -q dialog "dialogcheck.txt"; then
    printf "+ ${green}Dialog has been installed. Proceeding.${nc}\n"
    rm dialogcheck.txt
    fi
fi

HEIGHT=15
WIDTH=50
CHOICE_HEIGHT=8
BACKTITLE="SECSUITE INFRAMON INSTALLER CONSOLE -- SESSION STARTED AT: $(date)"
TITLE="SECSUITE BETA Release v0.01 (Inframon Installers)"
MENU="MENU OPTIONS: "

OPTIONS=(1 "Configure Apache Monitor"
         2 "Configure CPU Load Monitor"
         3 "Configure New Node CPU Monitor"
         4 "Configure Network Latency Monitor"
         5 "Configure CPU Temperature Monitor"
         6 "Configure Dashboard (BETA)"
         7 "Configure New Remote Node")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)

        bash /root/scripts/SECSUITE/inframon/apache-monitor-installer-local.sh

        read -p "Would you like to return to the console? (y/n):  " -n 1 -r
        echo #
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
        bash /root/scripts/SECSUITE/inframon/complete-local-setup.sh
        fi
        ;;

        2)

        bash /root/scripts/SECSUITE/inframon/cpu-load-average-monitor-installer.sh

        read -p "Would you like to return to the console? (y/n):  " -n 1 -r
        echo #
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
        bash /root/scripts/SECSUITE/inframon/complete-local-setup.sh
        fi
        ;;

        3)

        bash /root/scripts/SECSUITE/inframon/cpu-load-new-node-installer.sh

        read -p "Would you like to return to the console? (y/n):  " -n 1 -r
        echo #
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
        bash /root/scripts/SECSUITE/inframon/complete-local-setup.sh
        fi
        ;;

        4)

        bash /root/scripts/SECSUITE/inframon/latency-monitor-installer-local.sh

        read -p "Would you like to return to the console? (y/n):  " -n 1 -r
        echo #
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
        bash /root/scripts/SECSUITE/inframon/complete-local-setup.sh
        fi
        ;;

        5)

        bash /root/scripts/SECSUITE/inframon/temperature-monitor-install.sh

        read -p "Would you like to return to the console? (y/n):  " -n 1 -r
        echo #
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
        bash /root/scripts/SECSUITE/inframon/complete-local-setup.sh
        fi
        ;;

        6)

        echo "This feature is currently in development."

        read -p "Would you like to return to the console? (y/n):  " -n 1 -r
        echo #
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
        bash /root/scripts/SECSUITE/inframon/complete-local-setup.sh
        fi
        ;;

        7)

        while true; do
            read -p "Do you wish to store the monitoring data locally on this server (Y) or on the node itself (N)? (Y/n): " yn
            case $yn in
                [Yy]* ) bash /root/scripts/SECSUITE/inframon/node-install/auto-discover-store-on-server.sh; break;;
                [Nn]* ) bash /root/scripts/SECSUITE/inframon/node-install/auto-discover-store-on-node.sh; break;;
                * ) echo "Please answer yes or no.";;
            esac
        done
        ;;
esac
