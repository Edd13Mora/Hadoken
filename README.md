# Hadoken.sh

`Hadoken` is a versatile bash script designed for network scanning and enumeration. Harnessing the power of various well-known security tools, `Hadoken` simplifies the scanning process and collates the results into an easily readable HTML report. Perfect for penetration testers and system administrators looking to evaluate the security posture of their networks.

![Banner or Screenshot](url-to-image-if-you-have-one)

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

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/hadoken.git
   cd hadoken
