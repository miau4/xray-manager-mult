```bash
#!/bin/bash

clear
echo "=== XRAY MODO TUNEL (VLESS) ==="

read -p "Endereço (ex: m.ofertas.tim.com.br): " ADDRESS
read -p "Porta (ex: 443): " PORT
read -p "UUID: " UUID
read -p "SNI (ex: www.tim.com.br): " SNI
read -p "Host (ex: azion): " HOST
read -p "Path (ex: /): " PATH

if [[ -z "$ADDRESS" || -z "$PORT" || -z "$UUID" ]]; then
  echo "Dados inválidos!"
  exit
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
      "tag": "socks",
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
      "tag": "proxy",
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
    },
    {
      "tag": "direct",
      "protocol": "freedom"
    },
    {
      "tag": "block",
      "protocol": "blackhole"
    }
  ]
}
EOF

systemctl restart xray

echo "XRAY_TUNEL=1" >> /etc/painel/data/services.conf

echo ""
echo "XRAY ATIVO NA PORTA 10808"
```
