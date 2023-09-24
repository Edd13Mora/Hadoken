#!/bin/bash

# Update system repositories
sudo apt-get update

# Install system packages
sudo apt-get install -y nmap smbclient

# Installing tools that might be available via package managers
sudo apt-get install -y enum4linux crackmapexec ldapdomaindump

# Manual installations (this is a general outline; you might need to adjust the commands)
# Example: Installing smbmap (you should check the latest release or preferred installation method)
git clone https://github.com/ShawnDEvans/smbmap.git
cd smbmap
sudo python3 -m pip install -r requirements.txt
sudo ln -s $PWD/smbmap.py /usr/local/bin/smbmap

# Make sure to have impacket, bloodhound-python, kerbrute and ldeep installed (Manualy)
