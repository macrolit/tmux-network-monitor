#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

get_cache_duration() {
    get_script_option "interface" "cache_duration" "45"
}

CACHE_DURATION=$(get_cache_duration)
CACHE_FILE="/tmp/tmux_interface_cache"

get_active_interface() {
    # Check if cache file exists and is not older than CACHE_DURATION
    if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt "$CACHE_DURATION" ]; then
        cat "$CACHE_FILE"
    else
        local interface=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
        if [ -n "$interface" ]; then
            echo "$interface" | tee "$CACHE_FILE"
        else
            echo "No active interface" | tee "$CACHE_FILE"
        fi
    fi
}

get_active_interface
