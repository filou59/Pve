#!/bin/bash

# Filou59 - 2021

# Script pour Retirer NAG et Fix Repo
# Utilisation :
# wget -q -O - https://raw.githubusercontent.com/filou59/Pve/main/Upd_pve_repo_nag.sh | bash

varversion=1.0
# V1.0: Initial Release with support for both PVE and PBS

echo "----------------------------------------------------------------"
echo "Filou59 - 2021"
echo "Proxmox subscription and sources inital setup V$varversion"
echo "----------------------------------------------------------------"
exit 0

# -----------------ENVIRONNEMENT VARIABLES----------------------
# Hostname used to generate sensor name
pve_log_folder="/var/log/pve/tasks/"
proxmoxlib="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"
distribution=$(. /etc/*-release;echo $VERSION_CODENAME)
# ---------------END OF ENVIRONNEMENT VARIABLES-----------------
# Disable Commercial Repo
#sed -i "s/^deb/\#deb/" /etc/apt/sources.list.d/pve-enterprise.list && apt-get update

# Add PVE Community Repo
#echo "deb http://download.proxmox.com/debian/pve $(grep "VERSION=" /etc/os-release | sed -n 's/.*(\(.*\)).*/\1/p') pve-no-subscription" > /etc/apt/sources.list.d/pve-no-enterprise.list && apt-get update

# Check if server is PBS or PVE using /var/log/pve/tasks/
if [ -d "$pve_log_folder" ]; then
  echo "- Server is a PVE host"
#2: Edit sources list:
  echo "- Checking Sources list"
    if grep -Fxq "deb http://download.proxmox.com/debian/pve $distribution pve-no-subscription" /etc/apt/sources.list
     then
      echo "-- Source looks alredy configured - Skipping"
    else
      echo "-- Adding new entry to sources.list"
      sed -i "\$adeb http://download.proxmox.com/debian/pve $distribution pve-no-subscription" /etc/apt/sources.list
    fi
  echo "- Checking Enterprise Source list"
    if grep -Fxq "#deb https://enterprise.proxmox.com/debian/pve $distribution pve-enterprise" /etc/apt/sources.list.d/pve-enterprise.list
    then
     echo "-- Entreprise repo looks already commented - Skipping"
    else
     echo "-- Hiding Enterprise sources list"
     sed -i 's/^/#/' /etc/apt/sources.list.d/pve-enterprise.list
   fi
else
  echo "- Server is a PBS host"
  echo "- Checking Sources list"
    if grep -Fxq "deb http://download.proxmox.com/debian/pbs $distribution pbs-no-subscription" /etc/apt/sources.list
    then
      echo "-- Source looks alredy configured - Skipping"
    else
     echo "-- Adding new entry to sources.list"
      sed -i "\$adeb http://download.proxmox.com/debian/pbs $distribution pbs-no-subscription" /etc/apt/sources.list
    fi
  echo "- Checking Enterprise Source list"
    if grep -Fxq "#deb https://enterprise.proxmox.com/debian/pbs $distribution pbs-enterprise" /etc/apt/sources.list.d/pbs-enterprise.list
      then
      echo "-- Entreprise repo looks already commented - Skipping"
    else
      echo "-- Hiding Enterprise sources list"
      sed -i 's/^/#/' /etc/apt/sources.list.d/pbs-enterprise.list
    fi
fi

#3: update:
echo "- Updating System"
apt-get update -y -qq
apt-get upgrade -y -qq
apt-get dist-upgrade -y -qq

#4: Remove Subscription:
#checking if file is already edited in order to not edit again
if grep -Ewqi "void" $proxmoxlib; then
echo "- Subscription Message already removed - Skipping"
else
if [ -d "$pve_log_folder" ]; then
echo "- Removing No Valid Subscription Message for PVE"
#sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" $proxmoxlib && systemctl restart pveproxy.service
echo "DPkg::Post-Invoke { \"dpkg -V proxmox-widget-toolkit | grep -q '/proxmoxlib\.js$'; if [ \$? -eq 1 ]; then { echo 'Removing subscription nag from UI...'; sed -i '/data.status/{s/\!//;s/Active/NoMoreNagging/}' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js; }; fi\"; };" > /etc/apt/apt.conf.d/no-nag-script && apt --reinstall install proxmox-widget-toolkit
else 
echo "- Removing No Valid Subscription Message for PBS"
sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('No valid sub)/void\(\{ \/\/\1/g" $proxmoxlib && systemctl restart proxmox-backup-proxy.service
fi
fi

