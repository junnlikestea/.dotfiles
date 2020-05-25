#!/bin/sh
pid=$(pgrep -x openvpn)
size=${#pid}

if [ "$size" -gt 0 ]; then
	server=$(protonvpn status | sed -n '4p' | awk '{print $1,$2}')
	zone=$(protonvpn status | sed -n '2p' | awk '{print $1,$2}')
	echo "$zone $server";
else
	echo "Vpn off";
fi
