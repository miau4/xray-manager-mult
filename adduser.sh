#!/bin/bash

read -p "Nome do usuario: " user

UUID=$(uuidgen)

IP=$(curl -s ifconfig.me)

CONFIG="/etc/xray/config.json"

jq --arg id "$UUID" '.inbounds[0].settings.clients += [{"id":$id}]' $CONFIG > /tmp/config.json
mv /tmp/config.json $CONFIG

echo "$user:$UUID" >> /etc/xray-manager/users.db

systemctl restart xray

echo ""
echo "Usuario criado"
echo ""

echo "LINK:"
echo ""

echo "vless://$UUID@$IP:443?security=reality&type=tcp&sni=www.cloudflare.com&flow=xtls-rprx-vision#$user"
