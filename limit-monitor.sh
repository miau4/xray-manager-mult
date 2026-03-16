#!/bin/bash

LOG="/var/log/xray/access.log"
LIMITDB="/etc/xray-manager/limit.db"

while read line
do

USER=$(echo $line | cut -d: -f1)
LIMIT=$(echo $line | cut -d: -f2)

COUNT=$(grep $USER $LOG | wc -l)

if [ "$COUNT" -gt "$LIMIT" ]; then
echo "Usuario $USER excedeu limite"
systemctl restart xray
fi

done < $LIMITDB
