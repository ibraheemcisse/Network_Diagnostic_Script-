#!/bin/bash

check_connectivity() {
    local host=$1  # Get the hostname/IP as first argument
    
    ping -c 3 -W 2 $host > /dev/null 2>&1  # Suppress output for now
    
    if [ $? -eq 0 ]; then
        echo "✓ $host is reachable"
        return 0
    else
        echo "✗ $host is unreachable"
        return 1
    fi
}

main() {
    echo "=== Network Diagnostics ==="
    check_connectivity 8.8.8.8
    echo "=== Complete ==="
}

# Call main function
main "$@"