#!/bin/bash

CONFIG="/etc/xray/config.json"

if ! jq empty "$CONFIG" 2>/dev/null; then
    echo "❌ JSON corrompido! Tentando restaurar..."

    cp /etc/xray/config.backup.json "$CONFIG" 2>/dev/null

    systemctl restart xray
    echo "✔ Restaurado backup!"
else
    echo "✔ JSON válido"
fi
