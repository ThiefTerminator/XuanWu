#!/bin/bash
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Set variables
LIMIT=400                # Request count limit
FINDTIME=30              # Time window for searching (seconds)
BAN_TIME=1800            # Ban duration (seconds)
IP_LOG="your-web-log-dir.log"  # Nginx access log path
BLOCKED_IPS="blocked_ips" # ipset name

# Create IP set
ipset create -exist $BLOCKED_IPS hash:ip timeout $BAN_TIME

# Get the current time
CURRENT_TIME=$(date +%s)

# Find IPs with requests exceeding the limit
awk -v limit="$LIMIT" -v current_time="$CURRENT_TIME" -v findtime="$FINDTIME" '
{
    # Parse time
    split($4, datetime, ":")
    request_time = mktime(substr(datetime[1], 2, 4) " " substr(datetime[2], 1, 2) " " substr(datetime[3], 1, 2) " " substr(datetime[4], 1, 2) " " substr(datetime[5], 1, 2) " " substr(datetime[6], 1, 2))

    # Check if the request is for a .php file
    # Check for illegal request suffixes or if it contains type=custom
    if ($7 ~ /\.(php|sh|sql|jsp|asp|cgi)$/ || $7 ~ /[?&]type=custom/) {
        print $1  # Output the IP directly
    }

    # Process recent requests
    if (current_time - request_time <= findtime) {
        ip_count[$1]++
    }
}
END {
    for (ip in ip_count) {
        if (ip_count[ip] > limit) {
            print ip
        }
    }
}
' "$IP_LOG" | sort | uniq | while read ip; do
    # Add IP to ipset
    ipset add $BLOCKED_IPS $ip && echo "Blocked IP: $ip" || echo "Failed to block IP: $ip"
done

# Get the current list of blocked IPs
BLOCKED_IPS_LIST=$(ipset list $BLOCKED_IPS | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $1}')

# Loop through each blocked IP and add to iptables
for ip in $BLOCKED_IPS_LIST; do
    # Use regex to check IP format
    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ && $ip != "0.0.0.0" && $ip != "0.0.0.0/0" ]]; then
        if ! iptables -C INPUT -s $ip -j DROP &>/dev/null; then
            if iptables -I INPUT -s $ip -j DROP; then
                echo "Added to iptables: $ip"
            else
                echo "Failed to add $ip to iptables"
            fi
        else
            echo "iptables rule already exists: $ip"
        fi
    else
        echo "Skipping invalid IP: $ip"
    fi
done

# Check existing iptables rules and clean up expired IPs
EXISTING_IPS=$(iptables -L INPUT -v -n | awk '/DROP/ {print $8}' | sort -u)

# Check if EXISTING_IPS has any value
if [ -z "$EXISTING_IPS" ]; then
    echo "No DROP rules found."
else
    # Loop through existing iptables rules
    for existing_ip in $EXISTING_IPS; do
        # Check IP format
        if [[ $existing_ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] && [[ $existing_ip != "0.0.0.0" && $existing_ip != "0.0.0.0/0" ]]; then
            echo "Checking IP: $existing_ip"
            if ! echo "$BLOCKED_IPS_LIST" | grep -qw "$existing_ip"; then
                echo "Removing IP: $existing_ip"
                iptables -D INPUT -s "$existing_ip" -j DROP
                echo "Removed expired IP from iptables: $existing_ip"
            else
                echo "Keeping IP: $existing_ip"
            fi
        else
            echo "Invalid IP: $existing_ip, skipping deletion."
        fi
    done
fi
