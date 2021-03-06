#!/bin/bash

# Filou59 - 2021

# Script pour Retirer NAG et Fix Repo

# USAGE
# You can run this scritp directly using:
# wget -q -O - https://raw.githubusercontent.com/filou59/Pve/main/Upd_pve_repo_nag.sh | bash

varversion=1.0
# V1.0: Initial Release with support for both PVE and PBS

echo "----------------------------------------------------------------"
echo "Filou59 - 2021"
echo "Proxmox subscription and sources inital setup V$varversion"
echo "----------------------------------------------------------------"
exit 0
# -----------------ENVIRONNEMENT VARIABLES----------------------

# Disable Commercial Repo
sed -i "s/^deb/\#deb/" /etc/apt/sources.list.d/pve-enterprise.list 
apt-get update

# Add PVE Community Repo
echo "deb http://download.proxmox.com/debian/pve $(grep "VERSION=" /etc/os-release | sed -n 's/.*(\(.*\)).*/\1/p') pve-no-subscription" > /etc/apt/sources.list.d/pve-no-enterprise.list && apt-get update

# Remove nag
echo "DPkg::Post-Invoke { \"dpkg -V proxmox-widget-toolkit | grep -q '/proxmoxlib\.js$'; if [ \$? -eq 1 ]; then { echo 'Removing subscription nag from UI...'; sed -i '/data.status/{s/\!//;s/Active/NoMoreNagging/}' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js; }; fi\"; };" > /etc/apt/apt.conf.d/90no-nag-script
apt --reinstall install proxmox-widget-toolkit
