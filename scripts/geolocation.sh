#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

get_cache_duration() {
    get_script_option "geolocation" "cache_duration" "15"
}

CACHE_DURATION=$(get_cache_duration)
CACHE_FILE="/tmp/tmux_geolocation_cache"
LAN_CACHE_FILE="/tmp/lan_ip_cache"

get_location() {
    local current_lan_ip=""
    local cached_lan_ip=""
    local cached_result=""

    if [ -f "$LAN_CACHE_FILE" ]; then
        current_lan_ip=$(cat "$LAN_CACHE_FILE")
    fi

    if [ -f "$CACHE_FILE" ]; then
        cached_lan_ip=$(head -n 1 "$CACHE_FILE")
        cached_result=$(tail -n 1 "$CACHE_FILE")
    fi

    # Check if it's time to compare LAN IPs
    if [ ! -f "$CACHE_FILE" ] || [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -ge "$CACHE_DURATION" ]; then
        if [ "$current_lan_ip" != "$cached_lan_ip" ]; then
            # LAN IP has changed, fetch new geolocation data
            local geo_services=(
                "https://ipapi.co/json/"
                "https://ipinfo.io/json"
                "https://freegeoip.app/json/"
                "https://extreme-ip-lookup.com/json/"
            )
            
            local random_index=$((RANDOM % ${#geo_services[@]}))
            local selected_service=${geo_services[$random_index]}
            
            local json_response=$(curl -s --max-time 5 "$selected_service")
            
            local result=""
            case $selected_service in
                "https://ipapi.co/json/")
                    result=$(echo "$json_response" | grep -E '"city"|"region"|"country_name"' | awk -F'"' '{print $4}' | paste -sd ", " -)
                    ;;
                "https://ipinfo.io/json")
                    result=$(echo "$json_response" | grep -E '"city"|"region"|"country"' | awk -F'"' '{print $4}' | paste -sd ", " -)
                    ;;
                "https://freegeoip.app/json/")
                    result=$(echo "$json_response" | grep -E '"city"|"region_name"|"country_name"' | awk -F'"' '{print $4}' | paste -sd ", " -)
                    ;;
                "https://extreme-ip-lookup.com/json/")
                    result=$(echo "$json_response" | grep -E '"city"|"region"|"country"' | awk -F'"' '{print $4}' | paste -sd ", " -)
                    ;;
            esac

            result=$(echo "$result" | sed 's/, /, /g; s/,/, /g; s/  / /g; s/^[, ]*//; s/[, ]*$//')
            
            if [ -n "$result" ] && [ "$result" != ", , " ]; then
                echo -e "$current_lan_ip\n$result" > "$CACHE_FILE"
                echo "$result"
            else
                echo "Location Unavailable" | tee "$CACHE_FILE"
            fi
        else
            # LAN IP hasn't changed, update cache timestamp and return cached result
            touch "$CACHE_FILE"
            echo "$cached_result"
        fi
    else
        # Not time to check yet, return cached result
        echo "$cached_result"
    fi
}

echo "$(get_location)"
