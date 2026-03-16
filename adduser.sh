#!/bin/bash

CONFIG="/etc/xray/config.json"
KEYFILE="/etc/xray-manager/reality.key"

read -p "Nome do usuario: " user

UUID=$(uuidgen)

IP=$(curl -s ifconfig.me)

PUBLIC=$(grep PUBLIC $KEYFILE | cut -d= -f2)

SNI="www.cloudflare.com"
SID="6ba85179e30d4fc2"

jq --arg id "$UUID" '.inbounds[].settings.clients += [{"id":$id}]' $CONFIG > /tmp/config.json
mv /tmp/config.json $CONFIG

echo "$user:$UUID" >> /etc/xray-manager/users.db

systemctl restart xray

echo ""
echo "Usuario criado"
echo ""

echo "LINK VLESS REALITY:"
echo ""

echo "vless://$UUID@$IP:443?encryption=none&security=reality&type=tcp&sni=$SNI&fp=chrome&pbk=$PUBLIC&sid=$SID&flow=xtls-rprx-vision#$user"

echo ""
echo "LINKS GERADOS"
echo ""

echo "VLESS REALITY"
echo "vless://$UUID@$IP:443?security=reality&type=tcp&sni=www.cloudflare.com&fp=chrome&pbk=$PUBLIC&sid=6ba85179e30d4fc2&flow=xtls-rprx-vision#$user"

echo ""

echo "VLESS WS"
echo "vless://$UUID@$IP:80?type=ws&path=/vless&security=none#$user"

echo ""

echo "VMESS WS"
echo "vmess://$(echo -n "{\"v\":\"2\",\"ps\":\"$user\",\"add\":\"$IP\",\"port\":\"8080\",\"id\":\"$UUID\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"\",\"path\":\"/vmess\",\"tls\":\"\"}" | base64 -w0)"

echo ""

echo "VLESS TCP"
echo "vless://$UUID@$IP:8880?type=tcp&security=none#$user"
