#!/bin/sh
status=$(protonvpn status | sed -n '1p' | awk '{print $1,$2'})
echo "$status"
