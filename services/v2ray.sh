
```bash
#!/bin/bash

clear
echo "=== INSTALAÇÃO XRAY ==="

read -p "Porta do Xray: " PORT
read -p "SNI/Domínio (opcional): " SNI

apt install curl -y

bash <(curl -Ls https://github.com/XTLS/Xray-install/raw/main/install-release.sh)

mkdir -p /etc/xray

cat > /etc/xray/config.json <<EOF
{
  "inbounds": [
    {
      "port": $PORT,
      "protocol": "vmess",
      "settings": {}
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOF

systemctl restart xray

echo "XRAY_ATIVO=1" >> /etc/painel/data/services.conf

echo "Xray instalado!"
```
