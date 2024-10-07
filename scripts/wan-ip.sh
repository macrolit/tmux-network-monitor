#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

LAN_CACHE_FILE="/tmp/lan_ip_cache"
WAN_CACHE_FILE="/tmp/wan_ip_cache"

get_cache_duration() {
    get_script_option "lan-ip" "cache_duration" "15"
}

CACHE_DURATION=$(get_cache_duration)

get_lan_ip() {
    ip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | head -n1)
    echo "$ip"
}

get_wan_ip() {
    local ip_services=(
        "https://api.ipify.org?format=text"
        "https://ifconfig.me/ip"
        "https://icanhazip.com"
        "https://ident.me"
        "https://ipecho.net/plain"
        "https://myexternalip.com/raw"
        "https://wtfismyip.com/text"
        "https://checkip.amazonaws.com"
        "https://ip.seeip.org"
        "https://api.ip.sb/ip"
    )
    
    local random_index=$((RANDOM % ${#ip_services[@]}))
    local selected_service=${ip_services[$random_index]}
    
    local wan_ip=$(curl -s -4 "$selected_service")
    
    # Validate IPv4 format
    if [[ $wan_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$wan_ip"
        # For debugging
        echo "DEBUG: IPv4 retrieved from $selected_service" >&2
    else
        echo "ERROR: Invalid IPv4 address retrieved" >&2
        return 1
    fi
}

check_and_get_wan_ip() {
    local current_lan_ip=$(get_lan_ip)
    local cached_lan_ip=""
    local cached_wan_ip=""

    if [ -f "$LAN_CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$LAN_CACHE_FILE"))) -lt "$CACHE_DURATION" ]; then
        cached_lan_ip=$(cat "$LAN_CACHE_FILE")
    fi

    if [ -f "$WAN_CACHE_FILE" ]; then
        cached_wan_ip=$(cat "$WAN_CACHE_FILE")
    fi

    if [ "$current_lan_ip" != "$cached_lan_ip" ] || [ -z "$cached_wan_ip" ]; then
        new_wan_ip=$(get_wan_ip)
        if [ $? -eq 0 ]; then
            echo "$current_lan_ip" > "$LAN_CACHE_FILE"
            echo "$new_wan_ip" > "$WAN_CACHE_FILE"
            echo "$new_wan_ip"
        else
            echo "ERROR: Failed to retrieve valid IPv4 address" >&2
            return 1
        fi
    else
        echo "$cached_wan_ip"
    fi
}

# Main execution
wan_ip=$(check_and_get_wan_ip)
if [ $? -eq 0 ]; then
    echo "$wan_ip"

    # Debugging information
    #echo "DEBUG: LAN IP: $(cat "$LAN_CACHE_FILE")"
    #echo "DEBUG: WAN IP cache file: $WAN_CACHE_FILE"
    #echo "DEBUG: LAN IP cache file: $LAN_CACHE_FILE"
    #echo "DEBUG: Cache duration: $CACHE_DURATION seconds"
else
    echo "Failed to retrieve WAN IP" >&2
fi
