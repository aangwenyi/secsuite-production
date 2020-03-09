<p align="center">
<img src="http://securitechsystems.ca/img/secsuite-github.png" title="Secsuite Logo">
</p>  

# SECSUITE BETA Release v1.2

## Created & Maintained by Daniel Ward
The purpose of SECSUITE is to allow easy workflows & automated threat management to UNIX Systems Administrators.

### Within SECSUITE Free Tier:
#### Ubuntu hosts only

#### SECSUITE Inframon Basic:
- Apache Web Server Monitor
- Network Latency Monitor
- Users Monitor

### Available upon purchasing SECSUITE Premium: 
#### Ubuntu & Debian hosts

#### SECSUITE Inframon Advanced:
<p align="center">
<img src="http://securitechsystems.ca/img/inframon.JPG" title="Inframon Diagram (Single Host)">
</p>

<p align="center">
<img src="http://securitechsystems.ca/img/inframondashboard.JPG" title="Inframon Dashboard">
</p>

- Apache Web Server Monitor
- CPU Monitor (Load Avg & Temperatures).
- Network Latency Monitor
- Users Monitor
- System Dashboard (to view the data from the above monitored sensors)

To install Inframon, execute "SECSUITE/inframon/complete-local-setup.sh"; You will have the option to install the local installers or add a new Remote Node.

#### File Management:
<p align="center">
<img src="http://securitechsystems.ca/img/leroy.JPG" title="Leroy Diagram (Multi-Host)">
</p>

- LEROY File Manager (Previously named JENKINS) Send, Backup & Delete files to/from configured remote hosts.
#### Server Monitoring / Notifications:
<p align="center">
<img src="http://securitechsystems.ca/img/system_monitor.JPG" title="System Monitor Diagram">
</p>  

- System Monitor (Heavy Processes, Disk Spaces, Logged Users) with email notifications.
#### 100% Entropic Credentials:
<p align="center">
<img src="http://securitechsystems.ca/img/imgpassauth.JPG" title="imgPassAuth Diagram">
</p>  

- imgPassAuth The thesis of imgPassAuth is to generate 100% random sha512 hashes by generating a hash of a unique image. The unique image itself (for optimal results) shall be a screenshot of a live webcam stream, or multiple streams.
#### Logblocker
- Logblocker detects and blocks attackers who are attempting to brute-force your SSH server ports, it is able to detect & block IP addresses according to the threshold of attacks (default = 5)
#### Installation Guides / Scripts:
<p align="center">
<img src="http://securitechsystems.ca/img/auto-discovery-network-install.png" title="Installation Diagram (Multi-Host)">
</p>  

- Installation Scripts to aid the installation & configuration of local & remote hosts for all programs.

Ensure to place SECSUITE/* in the directory: /root/scripts/SECSUITE/*
