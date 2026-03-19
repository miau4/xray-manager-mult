#!/bin/bash

clear

while true; do
echo "======================================="
echo "           XRAY MANAGER"
echo "======================================="
echo "1) Instalar Xray (VLESS)"
echo "2) Reiniciar Xray"
echo "3) Status"
echo "4) Remover Xray"
echo "0) Voltar"
echo "======================================="
read -p "Escolha: " op

case $op in

1)
clear
echo "=== XRAY VLESS TUNEL ==="

read -p "Address: " ADDRESS
read -p "Porta: " PORT
read -p "UUID: " UUID
read -p "SNI: " SNI
read -p "Host: " HOST
read -p "Path: " PATH

if [[ -z "$ADDRESS" || -z "$PORT" || -z "$UUID" ]]; then
  echo "Dados inválidos!"
  read -p "Enter..."
  continue
fi

apt install curl -y

bash <(curl -Ls https://github.com/XTLS/Xray-install/raw/main/install-release.sh)

mkdir -p /etc/xray

cat > /etc/xray/config.json <<EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 10808,
      "protocol": "socks",
      "settings": {
        "auth": "noauth",
        "udp": true
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": "$ADDRESS",
            "port": $PORT,
            "users": [
              {
                "id": "$UUID",
                "encryption": "none"
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "xhttp",
        "security": "tls",
        "xhttpSettings": {
          "path": "$PATH",
          "host": "$HOST"
        },
        "tlsSettings": {
          "serverName": "$SNI",
          "allowInsecure": true
        }
      }
    }
  ]
}
EOF

systemctl restart xray

LINK="vless://${UUID}@${ADDRESS}:${PORT}?encryption=none&type=xhttp&security=tls&sni=${SNI}&host=${HOST}&path=${PATH}#NETSIMON"

echo ""
echo "XRAY ATIVO!"
echo "LINK GERADO:"
echo "$LINK"

read -p "Enter..."
;;

2)
systemctl restart xray
echo "Reiniciado!"
read -p "Enter..."
;;

3)
systemctl status xray --no-pager
read -p "Enter..."
;;

4)
systemctl stop xray
apt remove xray -y
rm -rf /etc/xray
echo "Removido!"
read -p "Enter..."
;;

0)
break
;;

*)
echo "Opção inválida!"
;;

esac
done
