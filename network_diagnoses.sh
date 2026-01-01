#!/bin/bash

# =============================================
# Network Diagnostic Script
# =============================================

# ICMP connectivity check
check_connectivity() {
    local host=$1

#check if host is reachable via ping

    if ping -c 3 -W 2 "$host" >/dev/null 2>&1; then

#ping 3 times with a wait of 2 seconds and suppress output

        echo "✓ $host is reachable (ICMP)"
        return 0
    else
        echo "✗ $host is unreachable (ICMP)"
        return 1
    fi
}

# DNS resolution check
check_dns() {
    local domain=$1
    local result

#use dig to resolve domain and get only the first A record

    result=$(dig +short A "$domain" 2>/dev/null | head -n1)

#logic to check if result is non-empty and print appropriate message
    if [[ -n "$result" ]]; then
        echo "✓ $domain resolves to $result"
        return 0
    else
        echo "✗ $domain failed to resolve"
        return 1
    fi
}

check_listening_ports() {
    echo "Listening Ports:"

    ss -tlnp 2>/dev/null | tail -n +2 | while read -r line; do
        # Extract local address
        local_addr=$(echo "$line" | awk '{print $4}')
        
        # Extract process name (users:(("nginx",pid=1234,fd=6))) safely
        if [[ "$line" =~ users:\(\(\"([^\"]+)\" ]]; then
            proc_name="${BASH_REMATCH[1]}"
            printf "  TCP %-20s → %s\n" "$local_addr" "$proc_name"
        else
            printf "  TCP %-20s\n" "$local_addr"
        fi
    done

}

# Port availability check
check_port() {
    local host=$1
    local port=$2
    local service=$3

#check that the host and port are reachable using bash's /dev/tcp feature with a timeout of 2 seconds
    
    timeout 2 bash -c "</dev/tcp/$host/$port" 2>/dev/null
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        if [[ -n $service ]]; then
            echo "✓ $host:$port is open ($service)"
        else
            echo "✓ $host:$port is open"
        fi
        return 0
    elif [[ $exit_code -eq 124 ]]; then
        if [[ -n $service ]]; then
            echo "⏱ $host:$port timed out ($service)"
        else
            echo "⏱ $host:$port timed out"
        fi
        return 1
    else
        if [[ -n $service ]]; then
            echo "✗ $host:$port is closed ($service)"
        else
            echo "✗ $host:$port is closed"
        fi
        return 1
    fi
}
# TCP state summary
check_tcp_states() {
    echo "TCP Connection States:"
    
    # Get all states (skip header), count each type
    local output=$(ss -tan | awk 'NR>1 {print $1}' | sort | uniq -c | sort -rn)
    
    # Display formatted
    if [[ -n "$output" ]]; then
        echo "$output" | while read count state; do
            printf "  %-15s %s\n" "$state:" "$count"
        done
    else
        echo "  No TCP connections found"
    fi
}

check_interfaces() {
    echo "Network Interfaces:"

    # Use brief mode for easier parsing
    # Format: iface STATE ADDR...
    ip -br addr show | while read -r iface state rest; do
        # Extract first IPv4 address (skip /24 suffix)
        ip_addr=$(echo "$rest" | awk '{for(i=1;i<=NF;i++){if($i ~ /^[0-9]+\./){print $i; exit}}}')

        if [[ "$state" == "UP" ]]; then
            if [[ -n "$ip_addr" ]]; then
                printf "  %-10s UP (%s)\n" "$iface:" "$ip_addr"
            else
                printf "  %-10s UP (no IP)\n" "$iface:"
            fi
        else
            printf "  %-10s DOWN\n" "$iface:"
        fi
    done
}

check_routes() {
    echo "Routing Table:"

    # Loop through each route entry
    while read -r line; do
        # Extract default gateway
        if [[ "$line" =~ ^default ]]; then
            # default via 192.168.1.1 dev wlp2s0 ...
            gw=$(echo "$line" | awk '{for(i=1;i<=NF;i++){if($i=="via"){print $(i+1); break}}}')
            dev=$(echo "$line" | awk '{for(i=1;i<=NF;i++){if($i=="dev"){print $(i+1); break}}}')
            echo "  Default gateway: $gw via $dev"

        # Local networks (prefix /XX)
        elif [[ "$line" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+ ]]; then
            # get network
            network=$(echo "$line" | awk '{print $1}')
            dev=$(echo "$line" | awk '{for(i=1;i<=NF;i++){if($i=="dev"){print $(i+1); break}}}')
            # Check if link down
            link_status=$(echo "$line" | grep -q "linkdown" && echo " (link down)" || echo "")
            echo "  Local network: $network dev $dev$link_status"

        else
            # any other route
            echo "  Route: $line"
        fi
    done < <(ip route show)
}

# Main diagnostic runner
# Main diagnostic runner
main() {
    echo "=== Network Diagnostics ==="
    echo ""
    
    check_connectivity 8.8.8.8
    echo ""
    
    check_dns google.com
    check_dns github.com
    echo ""
    
    check_interfaces
    echo ""
    
    check_routes
    echo ""
    
    check_port localhost 5432 "PostgreSQL"
    check_port localhost 5000 "Flask"
    check_port localhost 80 "nginx"
    echo ""
    
    check_tcp_states
    echo ""
    
    check_listening_ports
    echo ""
    
    echo "=== Complete ==="
}

main "$@"
