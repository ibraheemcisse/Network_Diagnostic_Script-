#!/bin/bash

# =============================================
# Network Diagnostic Script
# Author: Ibrahim
# Purpose: SRE network health checks
# =============================================

# ICMP connectivity check
check_connectivity() {
    local host=$1

    if ping -c 3 -W 2 "$host" >/dev/null 2>&1; then
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

    result=$(dig +short A "$domain" 2>/dev/null | head -n1)
    
    if [[ -n "$result" ]]; then
        echo "✓ $domain resolves to $result"
        return 0
    else
        echo "✗ $domain failed to resolve"
        return 1
    fi
}

# Port availability check
check_port() {
    local host=$1
    local port=$2
    local service=$3
    
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

# Main diagnostic runner
main() {
    echo "=== Network Diagnostics ==="
    echo ""
    
    check_connectivity 8.8.8.8
    echo ""
    
    check_dns google.com
    check_dns github.com
    echo ""
    
    check_port localhost 5432 "PostgreSQL"
    check_port localhost 5000 "Flask"
    check_port localhost 80 "nginx"
    echo ""
    
    echo "=== Complete ==="
}

main "$@"
