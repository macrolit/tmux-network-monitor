#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

CACHE_FILE="/tmp/geolocation_cache"

get_cache_duration() {
    get_script_option "coordinates" "cache_duration" "900"
}

# Replace CACHE_DURATION=900 with:
CACHE_DURATION=$(get_cache_duration)


get_coordinates() {
    # Try ipapi.co first
    local coords=$(curl -s --max-time 5 "https://ipapi.co/json/" | grep -E '"latitude"|"longitude"' | awk -F': ' '{print $2}' | tr -d ',"' | paste -sd ',' -)
    
    # If ipapi.co fails, try ipinfo.io
    if [ -z "$coords" ]; then
        coords=$(curl -s --max-time 5 "https://ipinfo.io/json" | grep '"loc"' | awk -F'"' '{print $4}')
    fi
    
    # If both fail, try geoiplookup.io
    if [ -z "$coords" ]; then
        coords=$(curl -s --max-time 5 "https://json.geoiplookup.io/" | grep -E '"latitude"|"longitude"' | awk -F': ' '{print $2}' | tr -d ',"' | paste -sd ',' -)
    fi

    echo "$coords"
}

format_coordinates() {
    local coords="$1"
    if [ -n "$coords" ]; then
        local lat=$(echo $coords | cut -d',' -f1)
        local lon=$(echo $coords | cut -d',' -f2)
        printf "%.4f, %.4f" $lat $lon
    else
        echo "Coordinates Unavailable"
    fi
}

main() {
    local current_time=$(date +%s)
    if [ -f "$CACHE_FILE" ] && [ $((current_time - $(stat -c %Y "$CACHE_FILE"))) -lt "$CACHE_DURATION" ]; then
        cat "$CACHE_FILE"
    else
        local coords=$(get_coordinates)
        local formatted_coords=$(format_coordinates "$coords")
        echo "$formatted_coords" | tee "$CACHE_FILE"
    fi
}

main
