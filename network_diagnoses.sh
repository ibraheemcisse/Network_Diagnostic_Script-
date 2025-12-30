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

    # Use dig to resolve domain (get first IPv4 address)
    result=$(dig +short A "$domain" 2>/dev/null | head -n1)
    
    if [[ -n "$result" ]]; then
        echo "✓ $domain resolves to $result"
        return 0
    else
        echo "✗ $domain failed to resolve"
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
    echo ""
    
    check_dns github.com
    echo ""
    
    echo "=== Complete ==="
}

# Run main
main "$@"
