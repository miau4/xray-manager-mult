#!/bin/bash

echo "Usuarios conectados"

grep accepted /var/log/xray/access.log | awk '{print $3}' | sort | uniq -c
