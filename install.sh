#!/bin/bash
set -e

clear

echo "================================="
echo "     INSTALANDO PAINEL NETSIMON"
echo "================================="

apt update -y
apt install -y curl jq uuid-runtime ufw

echo "Instalando Xray..."
bash <(curl -Ls https://github.com/XTLS/Xray-install/raw/main/install-release.sh)

mkdir -p /etc/xray
mkdir -p /etc/xray-manager
mkdir -p /var/log/xray

# ----------------- MONITOR AVANÇADO -----------------
cat > /etc/xray-manager/monitor.sh << 'EOF'
#!/bin/bash

while true; do
clear
echo "════════ MONITOR AVANÇADO ════════"
echo "1) Ver conexões (IP real)"
echo "2) Derrubar usuário"
echo "0) Voltar"
echo "══════════════════════════════════"

read -p "Escolha: " op

case $op in
    1)
        echo ""
        echo "Conexões ativas:"
        ss -tnp | grep xray | grep ESTAB
        echo ""
        read -p "Pressione ENTER..."
        ;;
    2)
        read -p "Usuário: " user
        xray api statsquery --reset --pattern "user>>>$user>>>*" 2>/dev/null
        echo "Usuário derrubado!"
        sleep 2
        ;;
    0) break ;;
    *) echo "Inválido"; sleep 1 ;;
esac
done
EOF

# ----------------- LIMITADOR ULTRA HARD (POR USUÁRIO) -----------------
cat > /etc/xray-manager/limit.sh << 'EOF'
#!/bin/bash

USERS="/etc/xray-manager/users.xray"
LOG="/var/log/xray/access.log"

while true; do
    [ ! -f "$USERS" ] && sleep 10 && continue
    [ ! -f "$LOG" ] && sleep 10 && continue

    while IFS="|" read -r user uuid exp pass limit; do

        # padrão = 1 conexão se não definido
        [ -z "$limit" ] && limit=1

        # pega IPs reais por UUID no log
        ips=$(grep "$uuid" "$LOG" | awk '{print $3}' | cut -d: -f1 | sort | uniq)

        total=$(echo "$ips" | grep -c .)

        if [ "$total" -gt "$limit" ]; then
            echo "[$(date)] $user excedeu limite ($total/$limit)"

            # derruba somente esse usuário
            xray api statsquery --reset --pattern "user>>>$user>>>*" 2>/dev/null
        fi

    done < "$USERS"

    sleep 30
done
EOF

# ----------------- EXPIRE CHECK -----------------
cat > /etc/xray-manager/expire-check.sh << 'EOF'
#!/bin/bash

USERS="/etc/xray-manager/users.xray"
CONFIG="/etc/xray/config.json"

[ ! -f "$USERS" ] && exit

now=$(date +%s)
tmpfile=$(mktemp)

while IFS="|" read -r user uuid exp pass limit; do
    exp_ts=$(date -d "$exp" +%s 2>/dev/null || echo 0)

    if [ "$exp_ts" -gt "$now" ]; then
        echo "$user|$uuid|$exp|$pass|$limit" >> $tmpfile
    else
        echo "Removendo expirado: $user"

        jq --arg uuid "$uuid" '
        (.inbounds[] | select(.protocol=="vless" or .protocol=="vmess") | .settings.clients) |= map(select(.id != $uuid))
        ' "$CONFIG" > /tmp/config.json && mv /tmp/config.json "$CONFIG"
    fi
done < $USERS

mv $tmpfile $USERS
systemctl restart xray
EOF

# ----------------- REALITY KEY -----------------
echo "Gerando chave Reality..."

KEYS=$(xray x25519)
PRIVATE=$(echo "$KEYS" | grep Private | awk '{print $3}')
PUBLIC=$(echo "$KEYS" | grep Public | awk '{print $3}')

echo "PRIVATE=$PRIVATE" > /etc/xray-manager/reality.key
echo "PUBLIC=$PUBLIC" >> /etc/xray-manager/reality.key

# ----------------- CONFIG XRAY -----------------
cat > /etc/xray/config.json <<EOF
{
"log": {
"access": "/var/log/xray/access.log",
"error": "/var/log/xray/error.log",
"loglevel": "warning"
},

"api": {
"services": ["HandlerService","LoggerService","StatsService"],
"tag": "api"
},

"stats": {},

"policy": {
"levels": {
"0": {
"statsUserDownlink": true,
"statsUserUplink": true,
"statsUserOnline": true
}
}
},

"inbounds": [
{
"tag": "api",
"listen": "127.0.0.1",
"port": 10085,
"protocol": "dokodemo-door",
"settings": {"address": "127.0.0.1"}
},

{
"port": 443,
"protocol": "vless",
"settings": {"clients": [],"decryption": "none"},
"streamSettings": {
"network": "xhttp",
"security": "tls",
"tlsSettings": {
"alpn": ["http/1.1"],
"certificates": [{
"certificateFile": "/etc/xray/fullchain.pem",
"keyFile": "/etc/xray/privkey.pem"
}]
},
"xhttpSettings": {"path": "/","host": ""}
}
},

{
"port": 8443,
"protocol": "vless",
"settings": {"clients": []},
"streamSettings": {
"network": "tcp",
"security": "reality",
"realitySettings": {
"dest": "www.cloudflare.com:443",
"serverNames": ["www.cloudflare.com"],
"privateKey": "$PRIVATE",
"shortIds": ["6ba85179e30d4fc2"]
}
}
},

{
"port": 80,
"protocol": "vless",
"settings": {"clients": []},
"streamSettings": {
"network": "ws",
"security": "none",
"wsSettings": {"path": "/vless"}
}
},

{
"port": 8080,
"protocol": "vmess",
"settings": {"clients": []},
"streamSettings": {
"network": "ws",
"security": "none",
"wsSettings": {"path": "/vmess"}
}
},

{
"port": 8880,
"protocol": "vless",
"settings": {"clients": []},
"streamSettings": {"network": "tcp","security": "none"}
}
],

"outbounds": [{"protocol": "freedom"}]
}
EOF

# ----------------- DOWNLOAD -----------------
curl -o /usr/local/bin/menu https://raw.githubusercontent.com/miau4/xray-manager-mult/main/menu.sh
curl -o /usr/local/bin/adduser https://raw.githubusercontent.com/miau4/xray-manager-mult/main/adduser.sh
curl -o /usr/local/bin/deluser https://raw.githubusercontent.com/miau4/xray-manager-mult/main/deluser.sh
curl -o /usr/local/bin/slowdns https://raw.githubusercontent.com/miau4/xray-manager-mult/main/slowdns.sh

# ----------------- PERMISSÕES -----------------
chmod +x /usr/local/bin/*
chmod +x /etc/xray-manager/*.sh

# ----------------- CRON LIMPO -----------------
crontab -l 2>/dev/null | grep -v 'expire-check.sh' | grep -v 'limit.sh' | crontab -

(crontab -l 2>/dev/null; echo "0 3 * * * /etc/xray-manager/expire-check.sh") | crontab -
(crontab -l 2>/dev/null; echo "@reboot nohup /etc/xray-manager/limit.sh >/dev/null 2>&1 &") | crontab -

# ----------------- FIREWALL -----------------
ufw allow 53
ufw allow 5300
ufw allow 80
ufw allow 443
ufw allow 8443
ufw allow 8080
ufw allow 8880

systemctl restart xray
systemctl enable xray

clear
echo "================================="
echo " INSTALAÇÃO CONCLUÍDA (ULTRA HARD)"
echo "================================="
echo "Formato users.xray:"
echo "usuario|uuid|validade|senha|limite"
echo ""
echo "Digite: menu"
