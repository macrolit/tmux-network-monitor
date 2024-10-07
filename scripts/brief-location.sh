#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

get_cache_duration() {
    get_script_option "brief-location" "cache_duration" "15"
}

CACHE_DURATION=$(get_cache_duration)
CACHE_FILE="/tmp/tmux_brief_location_cache"

get_country() {
    # Check if cache file exists and is not older than CACHE_DURATION
    if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt "$CACHE_DURATION" ]; then
        cat "$CACHE_FILE"
    else
        # Try to get the country from ipapi.co
        local country=$(curl -s --max-time 5 "https://ipapi.co/country_name/")
        
        # If the first attempt fails, try ipinfo.io
        if [ -z "$country" ]; then
            country=$(curl -s --max-time 5 "https://ipinfo.io/country")
        fi

        # If both attempts fail, use wget as a last resort
        if [ -z "$country" ]; then
            country=$(wget -qO- --timeout=5 "https://ipinfo.io/country")
        fi

        # Check if we got a valid response
        if [ -n "$country" ]; then
            echo "$country" | tee "$CACHE_FILE"
        else
            echo "Country Unavailable" | tee "$CACHE_FILE"
        fi
    fi
}

get_country
