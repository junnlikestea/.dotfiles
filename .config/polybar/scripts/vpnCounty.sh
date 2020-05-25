#!/bin/sh
server=$(protonvpn status | sed -n '4p' | awk '{print $1,$2}')
echo "$server"
