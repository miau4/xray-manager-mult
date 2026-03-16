#!/bin/bash

mkdir -p /etc/xray-manager/backup

cp /etc/xray/config.json /etc/xray-manager/backup/config-$(date +%F).json

echo "Backup realizado"
