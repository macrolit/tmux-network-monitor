#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

get_cache_duration() {
    get_script_option "bandwidth" "cache_duration" "1"
}

CACHE_DURATION=$(get_cache_duration)
CACHE_FILE="/tmp/tmux_bandwidth_cache"

get_bandwidth_for_osx() {
    netstat -ibn | awk 'FNR > 1 {
        interfaces[$1 ":bytesReceived"] = $(NF-4);
        interfaces[$1 ":bytesSent"] = $(NF-1);
    } END {
        for (itemKey in interfaces) {
            split(itemKey, keys, ":");
            interface = keys[1]
            dataKind = keys[2]
            sum[dataKind] += interfaces[itemKey]
        }
        print sum["bytesReceived"], sum["bytesSent"]
    }'
}

get_bandwidth_for_linux() {
    netstat -ie | awk '
        match($0, /RX([[:space:]]packets[[:space:]][[:digit:]]+)?[[:space:]]+bytes[:[:space:]]([[:digit:]]+)/, rx) { rx_sum+=rx[2]; }
        match($0, /TX([[:space:]]packets[[:space:]][[:digit:]]+)?[[:space:]]+bytes[:[:space:]]([[:digit:]]+)/, tx) { tx_sum+=tx[2]; }
        END { print rx_sum, tx_sum }
    '
}

get_bandwidth() {
    local os="$1"
    case $os in
        osx)
            echo -n $(get_bandwidth_for_osx)
            ;;
        linux)
            echo -n $(get_bandwidth_for_linux)
            ;;
        *)
            echo -n "0 0"
            ;;
    esac
}

format_speed() {
    local padding=5
    numfmt --to=iec-i --suffix "B/s" --format "%f" --padding $padding $1
}

os_type() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "osx";;
        *)          echo "unknown";;
    esac
}

calculate_and_format_speed() {
    local os=$(os_type)
    local first_measure=( $(get_bandwidth $os) )
    sleep $CACHE_DURATION
    local second_measure=( $(get_bandwidth $os) )
    local download_speed=$(((${second_measure[0]} - ${first_measure[0]}) / $CACHE_DURATION))
    local upload_speed=$(((${second_measure[1]} - ${first_measure[1]}) / $CACHE_DURATION))
    echo "↓$(format_speed $download_speed) • ↑$(format_speed $upload_speed)"
}

main() {
    # Check if cache file exists and is not older than CACHE_DURATION
    if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt "$CACHE_DURATION" ]; then
        cat "$CACHE_FILE"
    else
        calculate_and_format_speed | tee "$CACHE_FILE"
    fi
}

main
