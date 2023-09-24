#!/bin/bash


# Function to display help
usage() {
    echo "Usage: $0 -i IP [-s SCAN_TYPE] [-u USERNAME] [-p PASSWORD]"
    echo "  -i    target IP address"
    echo "  -s    optional scan type, one of: ping, quick, smb, classic, full, udp"
    echo "  -u    optional username (default: empty string)"
    echo "  -p    optional password (default: empty string)"
    echo "  -k    flag to indicate if kerbrute user enumeration should be executed"
    echo "  -U    path of the user file for kerbrute user enumeration"
    echo "  --help display this help message"
    exit 1
}

# Default values for the username and password
username=""
password=""
kerbrute_userlist=""

# Parsing command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i) ip="$2"; shift ;;
        -s) scan_type="$2"; shift ;;
        -u) username="$2"; shift ;;
        -p) password="$2"; shift ;;
        -U) kerbrute_userlist="$2"; shift ;;
        -k) kerbrute_flag=true; ;;
        --help) usage ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

# Check if IP argument is provided
if [[ -z "$ip" ]]; then
    usage
fi

# Create HTML report file
html_report="report.html"
echo "<html><head><meta charset='UTF-8'><meta name='viewport' content='width=device-width, initial-scale=1.0'>" > $html_report
echo "<title>Scan Report</title>" >> $html_report
echo "<link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css'>" >> $html_report
echo "<style>
    body {
        font-family: Arial, sans-serif;
        padding: 20px;
    }
    h1, h2, h3 {
        border-bottom: 1px solid #ddd;
        padding-bottom: 10px;
        margin-top: 20px;
        margin-bottom: 20px;
    }
    pre {
        background-color: #f4f4f4;
        padding: 10px;
        border-radius: 5px;
    }
    .container {
        max-width: 1200px;
        margin: auto;
    }
</style></head><body><div class='container'>" >> $html_report

echo "<h1>Scan Report</h1>" >> $html_report
echo "<p>Date: $(date)</p>" >> $html_report
echo "<hr>" >> $html_report

# Function to run command and append to HTML report
run_command() {
    local label="$1"
    local command="$2"

    echo "<div class='card mt-4'>
    <div class='card-header'>$label</div>
    <div class='card-body'><pre>" >> $html_report

    output=$(eval $command 2>&1)
    exit_code=$?
    
    if [ "$label" != "BloodHound" ]; then
        if [ $exit_code -ne 0 ]; then
            echo "Command failed with exit code $exit_code, moving on."
            output="Command failed with exit code $exit_code: $output"
        fi
        
        while IFS= read -r line; do
            if [[ "$line" == *"80/tcp   open"* ]]; then
                echo "<span style='color: orange;'>$line</span>" >> $html_report
            elif [[ "$line" == *"88/tcp   open"* ]]; then
                echo "<span style='color: orange;'>$line</span>" >> $html_report
            elif [[ "$line" == *"Domain:"* ]]; then
                echo "<span style='color: orange;'>$line</span>" >> $html_report
            elif [[ "$line" == *"Disk:"* ]]; then
                echo "<span style='color: green;'>$line</span>" >> $html_report
            elif [[ "$line" == *"succeeded:"* ]]; then
                echo "<span style='color: green;'>$line</span>" >> $html_report
            elif [[ "$line" == *"Sharename"* ]]; then
                echo "<span style='color: green;'>$line</span>" >> $html_report
            elif [[ "$line" == *"[+]"* ]]; then
                echo "<span style='color: green;'>$line</span>" >> $html_report
            elif [[ "$line" == *"ServicePrincipalName"* ]]; then
                echo "<span style='color: green;'>$line</span>" >> $html_report
            else
                echo "$line" >> $html_report
            fi
        done <<< "$output"
    else
        if [ $exit_code -ne 0 ]; then
            echo "<pre style='color: red;'>Something went wrong while running BloodHound.</pre>" >> $html_report
        else
            echo "<pre>The BloodHound results were generated and can be found in the '$bloodhound_output_folder' folder.</pre>" >> $html_report
        fi
    fi
    
    echo "</pre></div></div>" >> $html_report
    echo "$output"
}

# Function to check credentials using rpcclient
check_rpcclient_credentials() {
    output=$(echo "srvinfo" | rpcclient -U "${username}%${password}" "$ip")

    # Check the output to see if the credentials are likely to be correct
    if echo "$output" | grep -q "NT_STATUS_LOGON_FAILURE"; then
        result="Login failed: the username or password is incorrect"
    elif echo "$output" | grep -q "os version"; then
        result="Login succeeded: the username and password are likely to be correct"
    else
        result="An unexpected error occurred\nOutput was: $output"
    fi

    # Print the result in the terminal
    echo -e "$result"

    # Append the result to the HTML report
    echo "<h2>RPCclient Credential Check</h2><pre>" >> $html_report
    echo "$result" >> $html_report
    echo "</pre>" >> $html_report
}

# Perform an Nmap scan if specified
if [[ ! -z "$scan_type" ]]; then
    case $scan_type in
        ping) run_command "Network Scan - Ping Scan" "nmap -sP $ip";;
        quick) run_command "Network Scan - Quick Scan" "nmap -PN -sV --top-ports 50 --open $ip";;
        smb) run_command "Network Scan - Search SMB Vuln" "nmap -PN --script smb-vuln* -p139,445 $ip";;
        classic) run_command "Network Scan - Classic Scan" "nmap -PN -sV -oA nmap_classic_output.txt $ip";;
        full) run_command "Network Scan - Full Scan" "nmap -PN -sV -p- -oA nmap_full.txt $ip";;
        udp) run_command "Network Scan - UDP Scan" "nmap -sU -sC -sV -oA nmap_udp.txt $ip";;
        *) echo "Invalid scan type"; exit 1;;
    esac
fi

# Getting the domain name from the Nmap scan output
nmap_output=$(nmap -sV $ip)
domain_name=$(echo "$nmap_output" | grep -oP 'Domain: \K[^,]*' | head -1)



# If domain name was found, get the IP address of the domain
if [[ ! -z "$domain_name" ]]; then
    echo "Domain name found: $domain_name"
    echo "<h2>Domain Name</h2><pre style='color: green;'>$domain_name</pre>" >> $html_report
    nslookup_output=$(nslookup $domain_name)
    domain_ip=$(echo "$nslookup_output" | grep -oP 'Address: \K.*')
    if [[ ! -z "$domain_ip" ]]; then
        echo "Domain IP found: $domain_ip"
        echo "<h2>Domain IP</h2><pre style='color: green;'>$domain_ip</pre>" >> $html_report
    else
        echo "Domain IP not found"
        echo "<h2>Domain IP</h2><pre style='color: red;'>Not found</pre>" >> $html_report
    fi
else
    echo "Domain name not found in the Nmap output."
    echo "<h2>Domain Name</h2><pre style='color: red;'>Not found</pre>" >> $html_report
fi

# Adjustments in the command calls:
run_command "Enum4Linux Anonymous" "enum4linux   -u \"$username\" -p \"$password\" $ip"

# Adding smbmap and smbclient commands to the script
if [[ ! -z "$ip" ]]; then
    run_command "SMB Map " "smbmap -u \"$username\" -p \"$password\" -P 445 -H $ip"
    run_command "SMB Client" "smbclient -U \"$username%$password\" -L //$ip && smbclient -U 'guest%' -L //$ip"
fi

# Adding cme smb commands to the script
run_command "CME SMB With Creds" "crackmapexec smb $ip -u \"$username\" -p \"$password\""
run_command "CME SMB No Creds" "crackmapexec smb $ip -u '' -p ''"

# Running rpcclient command to check credentials
if [[ ! -z "$username" && ! -z "$password" ]]; then
    check_rpcclient_credentials
fi

# Execute bloodhound-python
bloodhound_output_folder="bloodhound_output"
mkdir -p "$bloodhound_output_folder"
run_command "BloodHound" "bloodhound-python -u \"$username\" -p \"$password\" -ns \"$ip\" -d \"$domain_name\" -c All"


# Execute impacket-GetUserSPNs
if [[ ! -z "$domain_name" && ! -z "$username" && ! -z "$password" && ! -z "$ip" ]]; then
    run_command "impacket-GetUserSPNs" "impacket-GetUserSPNs $domain_name/$username:$password -dc-ip $ip -request"
else
    echo "Missing parameters for impacket-GetUserSPNs"
    echo "<h2>impacket-GetUserSPNs</h2><pre style='color: red;'>Missing parameters for impacket-GetUserSPNs</pre>" >> $html_report
fi

#Ldap User Enumeration
if [[ ! -z "$domain_name" ]]; then
    run_command "LDeep User Enumeration (LDAP)" "ldeep ldap -u $username -p $password -d $domain_name -s ldap://$ip users"
else
    echo "LDeep User Enumeration failed. Domain name not defined."
    echo "<h2>LDeep User Enumeration (LDAP)</h2><pre style='color: red;'>LDeep User Enumeration failed. Domain name not defined.</pre>" >> $html_report
fi

run_command "LDAP Domain Dump" "ldapdomaindump -u $domain_name\\\\$username -p $password ldap://$ip -o ldap/"

#User enumeration kerberoas
if [[ $kerbrute_flag == true && -n "$kerbrute_userlist" && -n "$domain_name" && -n "$ip" ]]; then
    run_command "Kerbrute User Enumeration" "kerbrute userenum -d $domain_name --dc $ip $kerbrute_userlist"
else
    if [[ $kerbrute_flag == false ]]; then
        echo "Kerbrute User Enumeration skipped. -k flag not provided."
        echo "<h2>Kerbrute User Enumeration</h2><pre style='color: red;'>Kerbrute User Enumeration skipped. -k flag not provided.</pre>" >> $html_report
    else
        echo "Kerbrute User Enumeration failed. Domain name, IP, or Userlist not defined."
        echo "<h2>Kerbrute User Enumeration</h2><pre style='color: red;'>Kerbrute User Enumeration failed. Domain name, IP, or Userlist not defined.</pre>" >> $html_report
    fi
fi

# Close the HTML report
echo "</div></body></html>" >> $html_report

# Display a message indicating that the report has been generated
echo "Report generated: $html_report"
