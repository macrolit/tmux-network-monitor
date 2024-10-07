#!/usr/bin/env bash

LOADED_SEGMENTS=""


load_segments() {
    local segments=$(get_tmux_option "@modular_segments" "bandwidth")
    for segment in $segments; do
        if [ -f "$CURRENT_DIR/scripts/$segment.sh" ]; then
            source "$CURRENT_DIR/scripts/$segment.sh"
            LOADED_SEGMENTS+="$segment "
        fi
    done
}

get_tmux_option() {
    local option=$1
    local default_value=$2
    local option_value=$(tmux show-option -gqv "$option")
    if [ -z "$option_value" ]; then
        echo "$default_value"
    else
        echo "$option_value"
    fi
}

update_tmux_option() {
    local option=$1
    local new_value=""
    for segment in $LOADED_SEGMENTS; do
        new_value+="#($CURRENT_DIR/scripts/$segment.sh) "
    done
    tmux set-option -g "$option" "$new_value"
}

get_script_option() {
    local script=$1
    local option=$2
    local default_value=$3
    local tmux_option="@${script}_${option}"
    get_tmux_option "$tmux_option" "$default_value"
}
