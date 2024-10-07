#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/scripts/helpers.sh"




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

get_tmux_option() {
    local option=$1
    local default_value=$2
    local option_value=$(tmux show-option -gqv "$option")
    if [ -z "$option_value" ]; then
        echo $default_value
    else
        echo $option_value
    fi
}

main() {
	load_segments
	update_tmux_option "status-right"
	update_tmux_option "status-left"
	    
    if [ "$1" != "status" ]; then
        return
    fi

    local sleep_time=$(get_tmux_option "status-interval" 1)
    local os=$(os_type)
    local first_measure=( $(get_bandwidth $os) )
    sleep $sleep_time
    local second_measure=( $(get_bandwidth $os) )
    local download_speed=$(((${second_measure[0]} - ${first_measure[0]}) / $sleep_time))
    local upload_speed=$(((${second_measure[1]} - ${first_measure[1]}) / $sleep_time))
    echo -n "↓$(format_speed $download_speed) • ↑$(format_speed $upload_speed)"
}



main "$@"
