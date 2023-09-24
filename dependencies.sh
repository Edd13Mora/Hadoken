#!/bin/bash

# Update system repositories
sudo apt-get update

# Install system packages
sudo apt-get install -y nmap smbclient

# Installing tools that might be available via package managers
sudo apt-get install -y enum4linux crackmapexec ldapdomaindump

# Install BloodHound-Python
# Ensure you have pip3 installed: sudo apt-get install -y python3-pip
pip3 install bloodhound

# Install Kerbrute
cd /opt
wget https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64 -O kerbrute
chmod +x kerbrute
sudo mv kerbrute /usr/local/bin/

# LDeep might not have a direct installation process documented. As of my last training cut-off in January 2022, I don't have specifics about it.
# But if it's on GitHub or another platform, you'd typically:
# 1. Clone the repo
# 2. Change to its directory
# 3. Possibly run a build process or python setup.py install, etc.

# Example:
# git clone <ldeep_repo_url>
# cd ldeep
# python3 setup.py install OR ./build.sh (depending on the tool's installation documentation)
