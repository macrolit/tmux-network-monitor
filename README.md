## Custom Tmux Network Monitor

A lightweight, customizable tmux plugin for displaying network information in your TMUX status bar.

![preview](https://i.postimg.cc/m2WFpnjK/Screenshot-from-2024-10-15-21-38-42.png)

![preview](https://i.postimg.cc/T1J24tYX/Screenshot-from-2024-10-15-21-40-00.png)

## Features

- Lightweight
- Modular
- Wide array of optional segments
- Network bandwidth usage (download and upload speeds)
- Shows current IP address
- Customizable update intervals
- Works on both Linux and macOS

All segments are optional and customizable
## Installation

1. Clone this repository:

- text
    
    `git clone https://github.com/yourusername/tmux-network-monitor.git ~/.tmux/plugins/tmux-network-monitor`
    
- Add the plugin to your `.tmux.conf` file:
- text
    
    `run-shell ~/.tmux/plugins/tmux-network-monitor/network_monitor.tmux`
    
- Reload tmux configuration:

1. text
    
    `tmux source-file ~/.tmux.conf`
    

## Configuration

Add the following to your `.tmux.conf`:

text

`set -g status-right '#(~/.tmux/plugins/tmux-network-monitor/scripts/bandwidth.sh) | #(~/.tmux/plugins/tmux-network-monitor/scripts/ip_address.sh) | %H:%M %d-%b-%y'`

Adjust the path if you installed the plugin in a different location.

## Customization

- Edit `scripts/bandwidth.sh` to modify the network interface or update interval.
- Modify `scripts/ip_address.sh` to change how the IP address is displayed.

## Troubleshooting

If the plugin doesn't display correctly:

1. Ensure scripts are executable (`chmod +x scripts/*.sh`)
2. Check tmux version compatibility (`tmux -V`)
3. Verify script paths in your `.tmux.conf`
4. Run tmux in verbose mode for debugging: `tmux -v`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.









## Tmux Network Monitor Plugin

A tmux plugin that displays real-time network interface and bandwidth information in your tmux status bar.

## Features

- Displays active network interface
- Shows real-time download and upload speeds
- Configurable cache duration for performance optimization
- Works on both Linux and macOS systems

## Installation

## Manual Installation

1. Clone this repository:

text

`git clone https://github.com/yourusername/tmux-network-monitor.git ~/.tmux/plugins/tmux-network-monitor`

2. Add the plugin to your `.tmux.conf` file:

text

`run-shell ~/.tmux/plugins/tmux-network-monitor/network_monitor.tmux`

3. Reload tmux configuration:

text

`tmux source-file ~/.tmux.conf`

## Configuration

Add the following lines to your `.tmux.conf` file:

text

`set -g status-right-length 100 set -g status-right '#(~/.tmux/plugins/tmux-network-monitor/scripts/interface.sh) #(~/.tmux/plugins/tmux-network-monitor/scripts/bandwidth.sh)'`

replicate my config (images)

```lua
# StatusBar configuration here
set -g status-style bg=default
set-option -g default-terminal screen-256color
set-option -g automatic-rename on
set-option -g status-left-length 120
set-option -g status-right-length 120

set -g @tpm-debug 'on'
set -g status-interval 1

set-option -g status-left '\
#[fg=colour140,bold]#(echo " Session: ")#{session_name}  \
#[fg=colour69,bold]#(~/.tmux/plugins/tmux-network-monitor/scripts/interface.sh) \
#(~/.tmux/plugins/tmux-network-monitor/scripts/bandwidth.sh) \
#[fg=colour115,bold] #T '

set-option -g status-justify centre
set-option -g status-interval 10
set-option -g window-status-format '#{window_index} '
set-option -g window-status-current-format '#[fg=colour115,bold]#{window_index}#(echo ":")#{window_name} '

set -g status-right '\
#[fg=colour140,bold]#(whoami)  \
#[fg=colour148,bold]#(~/.tmux/plugins/tmux-network-monitor/scripts/wan-ip.sh) \
#[fg=colour36,bold]#(~/.tmux/plugins/tmux-network-monitor/scripts/lan-ip.sh)  \
#[fg=colour245,bold]#(~/.tmux/plugins/tmux-network-monitor/scripts/brief-location.sh) \
#[default,bold] %I:%M %p %a %h-%d '
```

## Optional: Customize Cache Duration

To change the cache duration (default is 1 second):

text

`set -g @bandwidth_cache_duration "5"`

## Troubleshooting

If the plugin isn't displaying correctly:

1. Ensure all scripts are executable:

text

`chmod +x ~/.tmux/plugins/tmux-network-monitor/scripts/*.sh`

2. Check tmux version (2.9 or later recommended):

text

`tmux -V`

3. Run tmux in verbose mode to check for errors:

text

`tmux -v`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
