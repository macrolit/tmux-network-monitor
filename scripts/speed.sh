#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

CACHE_FILE="/tmp/network_speed_cache"

get_cache_duration() {
    get_script_option "speed" "cache_duration" "900"
}

# Replace CACHE_DURATION=900 with:
CACHE_DURATION=$(get_cache_duration)

# ... (rest of the script remains the same)


# List of test files, each about 10MB or less
TEST_FILES=(
    "http://speedtest.ftp.otenet.gr/files/test10Mb.db"
    "http://speedtest.tele2.net/10MB.zip"
    "http://speedtest.belwue.net/10M"
    "http://speedtest-nyc1.digitalocean.com/10mb.test"
    "http://speedtest-ams2.digitalocean.com/10mb.test"
)

get_network_speed() {
    local max_speed=0
    for file in "${TEST_FILES[@]}"; do
        local speed=$(curl -o /dev/null -w "%{speed_download}" -s "$file")
        if (( $(echo "$speed > $max_speed" | bc -l) )); then
            max_speed=$speed
        fi
    done
    echo "$max_speed"
}

format_speed() {
    local speed=$1
    local speed_mbps=$(echo "scale=2; $speed * 8 / 1000000" | bc)
    printf "%.2f Mbps" $speed_mbps
}

main() {
    local current_time=$(date +%s)
    if [ -f "$CACHE_FILE" ] && [ $((current_time - $(stat -c %Y "$CACHE_FILE"))) -lt "$CACHE_DURATION" ]; then
        cat "$CACHE_FILE"
    else
        local download_speed=$(get_network_speed)
        local result="avg $(format_speed $download_speed)"
        echo "$result" | tee "$CACHE_FILE"
    fi
}

main
