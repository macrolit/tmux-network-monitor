#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

get_cache_duration() {
    get_script_option "hostname" "cache_duration" "10800"
}

CACHE_DURATION=$(get_cache_duration)
CACHE_FILE="/tmp/tmux_hostname_cache"

get_hostname() {
    # Check if cache file exists and is not older than CACHE_DURATION
    if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt "$CACHE_DURATION" ]; then
        cat "$CACHE_FILE"
    else
        hostname=$(hostname)
        echo "$hostname" | tee "$CACHE_FILE"
    fi
}

get_hostname
