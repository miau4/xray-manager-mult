#!/bin/bash

CONFIG="/etc/xray/config.json"

echo "Usuarios existentes:"
jq -r '.inbounds[0].settings.clients[].id' $CONFIG

echo ""
read -p "Digite o UUID que deseja remover: " UUID

jq --arg id "$UUID" '(.inbounds[0].settings.clients) |= map(select(.id != $id))' $CONFIG > /tmp/config.json

mv /tmp/config.json $CONFIG

systemctl restart xray

echo "Usuario removido"
