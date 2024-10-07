#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

get_cache_duration() {
    get_script_option "geolocation" "cache_duration" "900"
}

CACHE_DURATION=$(get_cache_duration)
CACHE_FILE="/tmp/tmux_geolocation_cache"

get_location() {
    # Check if cache file exists and is not older than CACHE_DURATION
    if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt "$CACHE_DURATION" ]; then
        cat "$CACHE_FILE"
        return
    fi

    # Primary method using ipapi.co
    local result=$(curl -s --max-time 5 "https://ipapi.co/json/" | grep -E '"city"|"region"|"country_name"' | awk -F'"' '{print $4}' | paste -sd ", " -)
    
    # Improve formatting
    result=$(echo "$result" | sed 's/, /, /g; s/,/, /g; s/  / /g')
    
    if [ -n "$result" ] && [ "$result" != ", , " ]; then
        echo "$result" | tee "$CACHE_FILE"
        return
    fi

    # Fallback to ipinfo.io using curl
    result=$(curl -s --max-time 5 "https://ipinfo.io/json" | grep -E '"city"|"region"|"country"' | awk -F'"' '{print $4}' | paste -sd ", " -)
    result=$(echo "$result" | sed 's/, /, /g; s/,/, /g; s/  / /g')
    
    if [ -n "$result" ] && [ "$result" != ", , " ]; then
        echo "$result" | tee "$CACHE_FILE"
        return
    fi

    # Final fallback using wget
    result=$(wget -qO- --timeout=5 "https://ipinfo.io/json" | grep -E '"city"|"region"|"country"' | awk -F'"' '{print $4}' | paste -sd ", " -)
    result=$(echo "$result" | sed 's/, /, /g; s/,/, /g; s/  / /g')
    
    if [ -n "$result" ] && [ "$result" != ", , " ]; then
        echo "$result" | tee "$CACHE_FILE"
        return
    fi

    echo "Location Unavailable" | tee "$CACHE_FILE"
}

get_location
