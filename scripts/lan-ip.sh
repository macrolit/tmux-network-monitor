#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

CACHE_FILE="/tmp/lan_ip_cache"

get_cache_duration() {
    get_script_option "lan-ip" "cache_duration" "15"
}

# Replace CACHE_DURATION=900 with:
CACHE_DURATION=$(get_cache_duration)


get_lan_ip() {
    if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt "$CACHE_DURATION" ]; then
        cat "$CACHE_FILE"
    else
        ip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n1)
        if [ -n "$ip" ]; then
            echo "$ip" > "$CACHE_FILE"
            echo "$ip"
        else
            echo "Unable to determine LAN IP"
        fi
    fi
}

lan_ip=$(get_lan_ip)
echo "$lan_ip"
