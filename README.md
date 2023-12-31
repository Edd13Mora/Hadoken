# Hadoken
<p align="center">
  <img src="https://raw.githubusercontent.com/Edd13Mora/Hadoken/main/a22d71635456ea129dede0d4651bd553-removebg-preview.png">
</p>

`Hadoken` is a versatile bash script designed for network scanning and enumeration. Harnessing the power of various well-known security tools, `Hadoken` simplifies the scanning process and collates the results into an easily readable HTML report. Perfect for penetration testers and system administrators looking to evaluate the security posture of their networks.

![Banner or Screenshot](https://raw.githubusercontent.com/Edd13Mora/Hadoken/main/demo1.png)
![Banner or Screenshot](https://raw.githubusercontent.com/Edd13Mora/Hadoken/main/demo2.png)
![Banner or Screenshot](https://raw.githubusercontent.com/Edd13Mora/Hadoken/main/demo3.png)
## Features

- Multiple scan types: `ping`, `quick`, `smb`, `classic`, `full`, `udp`.
- Generates comprehensive HTML reports.
- Integrated credential checking.
- User enumeration capabilities with Kerbrute.
- As-rep roastable users.
- LDAP Enumeration

## Prerequisites

Before you begin, ensure you have met the following requirements:

- A Linux-based system.
- Required tools and packages (all dependencies are listed in `dependencies.sh`).

## Installation
Clone this repository:
```bash
git clone https://github.com/Edd13Mora/Hadoken.git
cd hadoken
chmod +x dependencies.sh
./dependencies.sh
chmod +x hadoken.sh
```
## Usage
```bash
./hadoken.sh -i <IP_ADDRESS> [-s SCAN_TYPE] [-u USERNAME] [-p PASSWORD]
```
## For detailed options and usage:
```bash
./hadoken.sh --help
```
