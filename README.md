<p align="center">
<img src="http://securitechsystems.ca/img/secsuite-github.png" title="Secsuite Logo">
</p>  

# SECSUITE BETA Release v3.24420A

## Created & Maintained by Daniel Ward
The purpose of SECSUITE is to allow easy workflows & automated threat management to UNIX Systems Administrators.

#### Ubuntu & Debian hosts

#### SECSUITE Inframon Advanced:
<p align="center">
<img src="https://secsuite.net/images/inframon.JPG" title="Inframon Diagram (Single Host)">
</p>

<p align="center">
<img src="https://secsuite.net/images/inframondashboard.JPG" title="Inframon Dashboard">
</p>

<p align="center">
<img src="https://secsuite.net/images/inframoninstallers.png" title="Inframon Installers">
</p>  

- Apache Web Server Monitor
- Bandwidth Monitor
- CPU Monitor (Load Avg & Temperatures).
- Disk Usage Monitor
- Memory Monitor
- Network Latency Monitor
- Users Monitor
- Network Auto-Discovery Installation Included
- System Dashboard (to view the data from the above monitored sensors)

To install Inframon, execute "SECSUITE/inframon/complete-local-setup.sh"; You will have the option to install the local installers or add a new Remote Node.

#### File Management:
<p align="center">
<img src="https://secsuite.net/images/leroy.JPG" title="Leroy Diagram (Multi-Host)">
</p>

- LEROY File Manager (Previously named JENKINS) Send, Backup & Delete files to/from configured remote hosts.
#### Server Monitoring / Notifications:
<p align="center">
<img src="https://secsuite.net/images/system_monitor.JPG" title="System Monitor Diagram">
</p>  

- System Monitor (Heavy Processes, Disk Spaces, Logged Users) with email notifications.
#### 100% Entropic Credentials:
<p align="center">
<img src="https://secsuite.net/images/imgpassauth.JPG" title="imgPassAuth Diagram">
</p>  

- imgPassAuth The thesis of imgPassAuth is to generate 100% random sha512 hashes by generating a hash of a unique image. The unique image itself (for optimal results) shall be a screenshot of a live webcam stream, or multiple streams.
#### Logblocker
- Logblocker detects and blocks attackers who are attempting to brute-force your SSH server ports, it is able to detect & block IP addresses according to the threshold of attacks (default = 5)
#### Installation Guides / Scripts:
<p align="center">
<img src="https://secsuite.net/images/auto-discovery-network-install.png" title="Installation Diagram (Multi-Host)">
</p>  

#### Webinspector  
- A lightweight Apache Log Monitoring system, with backups inserted into MySQL for further analysis.  



- Installation Scripts to aid the installation & configuration of local & remote hosts for all programs.

Ensure to place SECSUITE/* in the directory: /root/scripts/SECSUITE/*
