#!/bin/bash

CONFIG="/etc/xray/config.json"
KEYFILE="/etc/xray-manager/reality.key"

read -p "Nome do usuario: " user

UUID=$(uuidgen)

IP=$(curl -s ifconfig.me)

PUBLIC=$(grep PUBLIC $KEYFILE | cut -d= -f2)

SNI="[www.cloudflare.com](http://www.cloudflare.com)"
SID="6ba85179e30d4fc2"

# adicionar cliente no VLESS xHTTP

jq '.inbounds[1].settings.clients += [{"id":"'"$UUID"'","email":"'"$user"'"}]' $CONFIG > /tmp/config.json
mv /tmp/config.json $CONFIG

# adicionar cliente no VLESS Reality

jq '.inbounds[2].settings.clients += [{"id":"'"$UUID"'","email":"'"$user"'"}]' $CONFIG > /tmp/config.json
mv /tmp/config.json $CONFIG

echo "$user:$UUID" >> /etc/xray-manager/users.db

systemctl restart xray

echo ""
echo "USUARIO CRIADO"
echo ""
echo "UUID: $UUID"
echo ""

echo "LINK VLESS XHTTP"
echo ""
echo "vless://$UUID@$IP:443?encryption=none&type=xhttp&security=tls&path=/#${user}"

echo ""
echo "LINK VLESS REALITY"
echo ""
echo "vless://$UUID@$IP:8443?encryption=none&security=reality&type=tcp&sni=$SNI&fp=chrome&pbk=$PUBLIC&sid=$SID&flow=xtls-rprx-vision#$user"

echo ""
echo "LINK VLESS WS"
echo ""
echo "vless://$UUID@$IP:80?type=ws&path=/vless&security=none#$user"

echo ""
echo "LINK VMESS WS"
echo ""
echo "vmess://$(echo -n "{"v":"2","ps":"$user","add":"$IP","port":"8080","id":"$UUID","aid":"0","net":"ws","type":"none","host":"","path":"/vmess","tls":""}" | base64 -w0)"

echo ""
echo "LINK VLESS TCP"
echo ""
echo "vless://$UUID@$IP:8880?type=tcp&security=none#$user"

echo ""
echo "LINKS GERADOS COM SUCESSO"
