#!/usr/bin/env bash

get_top_network_processes() {
    # Get the top 3 processes with network activity based on bandwidth
    if command -v nethogs >/dev/null 2>&1; then
        sudo nethogs -t -c 2 2>/dev/null | 
        tail -n +3 | 
        head -n 3 | 
        awk '{print $2}' | 
        xargs -I {} basename {} | 
        tr '\n' ',' | 
        sed 's/,$//'
    else
        echo "nethogs not installed"
    fi
}

main() {
    local top_processes=$(get_top_network_processes)
    
    if [ -n "$top_processes" ] && [ "$top_processes" != "nethogs not installed" ]; then
        echo "$top_processes"
    fi
}

main
