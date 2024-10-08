#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

get_cache_duration() {
    get_script_option "brief-location" "cache_duration" "15"
}

CACHE_DURATION=$(get_cache_duration)
CACHE_FILE="/tmp/tmux_brief_location_cache"
LAN_CACHE_FILE="/tmp/lan_ip_cache"

get_location() {
    local current_lan_ip=""
    local cached_lan_ip=""

    if [ -f "$LAN_CACHE_FILE" ]; then
        current_lan_ip=$(cat "$LAN_CACHE_FILE")
    fi

    # Check if cache file exists and is not older than CACHE_DURATION
    if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt "$CACHE_DURATION" ]; then
        tail -n 1 "$CACHE_FILE"
        return
    fi

    # If we've reached here, it's time to check if LAN IP has changed
    if [ -f "$CACHE_FILE" ]; then
        cached_lan_ip=$(head -n 1 "$CACHE_FILE")
        if [ "$current_lan_ip" = "$cached_lan_ip" ]; then
            # LAN IP hasn't changed, update cache timestamp and return cached result
            touch "$CACHE_FILE"
            tail -n 1 "$CACHE_FILE"
            return
        fi
    fi

    # If we've reached here, LAN IP has changed or there's no cache, so we need to fetch new data
    local geo_services=(
        "https://ipapi.co/json/"
        "https://ipinfo.io/json"
        "https://freegeoip.app/json/"
        "https://extreme-ip-lookup.com/json/"
    )
    
    local random_index=$((RANDOM % ${#geo_services[@]}))
    local selected_service=${geo_services[$random_index]}
    
    local result=""
    local json_response=$(curl -s --max-time 5 "$selected_service")
    
    case $selected_service in
        "https://ipapi.co/json/")
            result=$(echo "$json_response" | grep -E '"country_name"' | awk -F'"' '{print $4}')
            ;;
        "https://ipinfo.io/json")
            result=$(echo "$json_response" | grep -E '"country"' | awk -F'"' '{print $4}')
            ;;
        "https://freegeoip.app/json/")
            result=$(echo "$json_response" | grep -E '"country_name"' | awk -F'"' '{print $4}')
            ;;
        "https://extreme-ip-lookup.com/json/")
            result=$(echo "$json_response" | grep -E '"country"' | awk -F'"' '{print $4}')
            ;;
    esac

    result=$(echo "$result" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    if [ -n "$result" ] && [ "$result" != " " ]; then
        echo -e "$current_lan_ip\n$result" > "$CACHE_FILE"
        echo "$result"
    else
        echo "Unknown" | tee "$CACHE_FILE"
    fi
}

echo "$(get_location)"
