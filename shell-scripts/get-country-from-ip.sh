#!/bin/bash

# OUT_COUNTRY=$(curl -s http://ipinfo.io/$1 | grep country | awk -F: '{print $2}' | sed s/\"//g | sed s/,//)

OUT_COUNTRY=$(curl -s http://ipinfo.io/$1 | jq '.country' | sed s/\"//g)

echo "$1 $OUT_COUNTRY"