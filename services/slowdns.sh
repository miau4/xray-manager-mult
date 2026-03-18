```bash
#!/bin/bash

clear
echo "=== SLOWDNS (MODO INDEPENDENTE) ==="

read -p "NameServer (ex: ns1.seudominio.com): " NS
read -p "Chave (KEY): " KEY
read -p "DNS (ex: 8.8.8.8): " DNS

if [[ -z "$NS" || -z "$KEY" ]]; then
  echo "Dados inválidos!"
  exit
fi

echo "Instalando dependências..."
apt update -y
apt install wget curl -y

mkdir -p /etc/slowdns
cd /etc/slowdns || exit

echo "Baixando cliente SlowDNS..."

# ⚠️ TROQUE PELO BINÁRIO CORRETO QUE VOCÊ USA
wget -O slowdns https://raw.githubusercontent.com/miau4/slowdns-bin/main/slowdns

chmod +x slowdns

echo "Criando configuração..."

cat > /etc/slowdns/config.json <<EOF
{
  "key": "$KEY",
  "ns": "$NS",
  "dns": "$DNS"
}
EOF

echo "Criando serviço..."

cat > /etc/systemd/system/slowdns.service <<EOF
[Unit]
Description=SlowDNS Service
After=network.target

[Service]
ExecStart=/etc/slowdns/slowdns -config /etc/slowdns/config.json
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable slowdns
systemctl restart slowdns

echo "SLOWDNS_ATIVO=1" >> /etc/painel/data/services.conf

echo ""
echo "=== SLOWDNS ATIVO ==="
echo "NS: $NS"
echo "KEY: $KEY"
```
