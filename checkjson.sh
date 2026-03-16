#!/bin/bash

jq . /etc/xray/config.json > /dev/null 2>&1

if [ $? -eq 0 ]; then
 echo "JSON valido"
else
 echo "JSON quebrado"
fi
