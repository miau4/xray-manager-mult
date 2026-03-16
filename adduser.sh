#!/bin/bash

CONFIG="/etc/xray/config.json"
USERS="/etc/xray-manager/users.xray"
KEYFILE="/etc/xray-manager/reality.key"

# Criar arquivo de usuários se não existir
[ ! -f "$USERS" ] && touch "$USERS"

read -p "Nome do usuario: " user

UUID=$(uuidgen)
IP=$(curl -s ifconfig.me)
PUBLIC=$(grep PUBLIC $KEYFILE | cut -d= -f2)
SNI=$(jq -r '.inbounds[2].streamSettings.realitySettings.dest' $CONFIG)
SID="6ba85179e30d4fc2"

# Adicionar nos inbounds
jq ".inbounds[1].settings.clients += [{\"id\":\"$UUID\",\"email\":\"$user\"}]" $CONFIG > /tmp/config.json
mv /tmp/config.json $CONFIG
jq ".inbounds[2].settings.clients += [{\"id\":\"$UUID\",\"email\":\"$user\"}]" $CONFIG > /tmp/config.json
mv /tmp/config.json $CONFIG
jq ".inbounds[3].settings.clients += [{\"id\":\"$UUID\",\"email\":\"$user\"}]" $CONFIG > /tmp/config.json
mv /tmp/config.json $CONFIG

# Salvar no arquivo exclusivo
echo "$user:$UUID" >> $USERS

# Reiniciar Xray
systemctl restart xray

# Mostrar links
echo ""
echo -e "Usuario criado: ${GREEN}$user${NC}"
echo "UUID: $UUID"
echo ""
echo -e "${YELLOW}LINK VLESS XHTTP:${NC}"
echo "vless://$UUID@$IP:443?encryption=none&type=xhttp&security=tls&path=/#${user}"
echo ""
echo -e "${YELLOW}LINK VLESS REALITY:${NC}"
echo "vless://$UUID@$IP:8443?encryption=none&security=reality&type=tcp&sni=$SNI&fp=chrome&pbk=$PUBLIC&sid=$SID&flow=xtls-rprx-vision#$user"
echo ""
echo -e "${YELLOW}LINK VLESS WS:${NC}"
echo "vless://$UUID@$IP:80?type=ws&path=/vless&security=none#$user"
echo ""
echo -e "${YELLOW}LINK VMESS WS:${NC}"
echo "vmess://$(echo -n "{\"v\":\"2\",\"ps\":\"$user\",\"add\":\"$IP\",\"port\":\"8080\",\"id\":\"$UUID\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"\",\"path\":\"/vmess\",\"tls\":\"\"}" | base64 -w0)"
echo ""
echo -e "${YELLOW}LINK VLESS TCP:${NC}"
echo "vless://$UUID@$IP:8880?type=tcp&security=none#$user"
