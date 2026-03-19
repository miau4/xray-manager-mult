#!/bin/bash

clear
echo "=== INSTALANDO PAINEL BASE ==="

# -------------------------------
# VERIFICAR ROOT
# -------------------------------
if [ "$EUID" -ne 0 ]; then
    echo "Execute como root!"
    exit 1
fi

# -------------------------------
# CORRIGIR QUEBRA DE LINHA (CRLF)
# -------------------------------
sed -i 's/\r$//' "$0" 2>/dev/null

# -------------------------------
# ATUALIZAR E INSTALAR DEPENDÊNCIAS
# -------------------------------
apt update -y
apt install -y curl wget unzip jq

# -------------------------------
# CRIAR ESTRUTURA
# -------------------------------
mkdir -p /etc/painel/{core,services,data}
mkdir -p /etc/xray-manager

# -------------------------------
# BASE DO GITHUB
# -------------------------------
BASE_URL="https://raw.githubusercontent.com/miau4/PAINEL-NETSIMON/main"

# -------------------------------
# BAIXAR ARQUIVOS PRINCIPAIS
# -------------------------------
echo "[+] Baixando menu..."
wget -q -O /etc/painel/menu.sh $BASE_URL/menu.sh

echo "[+] Baixando config..."
wget -q -O /etc/painel/config.json $BASE_URL/config.json

# -------------------------------
# BAIXAR TODOS OS SCRIPTS
# (MESMA LÓGICA DO SEU PROJETO)
# -------------------------------
echo "[+] Baixando módulos..."

FILES=(
adduser.sh
api.sh
backup.sh
checkjson.sh
configjson
deluser.sh
expire-check.sh
expire-users.sh
expire.sh
limit-monitor.sh
limit.sh
listusers.sh
monitor.sh
online.sh
rebuild.sh
scheduler.sh
slowdns.sh
speedtest.sh
ssh-manager.sh
uninstall.sh
update.sh
)

for file in "${FILES[@]}"; do
    wget -q -O /etc/painel/$file $BASE_URL/$file
done

# -------------------------------
# GARANTIR BASE DE DADOS
# -------------------------------
touch /etc/xray-manager/users.xray
touch /etc/xray-manager/blocked.db

# -------------------------------
# PERMISSÕES
# -------------------------------
chmod -R +x /etc/painel

# -------------------------------
# COMANDO GLOBAL
# -------------------------------
ln -sf /etc/painel/menu.sh /usr/local/bin/menu
chmod +x /usr/local/bin/menu

# -------------------------------
# GARANTIR XRAY CONFIG
# -------------------------------
if [ ! -f /etc/xray/config.json ]; then
    echo "[+] Criando config do Xray..."
    mkdir -p /etc/xray
    cp /etc/painel/config.json /etc/xray/config.json
fi

nohup bash /etc/xray-manager/limit.sh >/dev/null 2>&1 &
nohup bash /etc/xray-manager/unblock.sh >/dev/null 2>&1 &
nohup bash /etc/xray-manager/expire-system.sh >/dev/null 2>&1 &

# -------------------------------
# TESTE FINAL
# -------------------------------
echo "[+] Testando menu..."
bash /etc/painel/menu.sh

echo ""
echo "===================================="
echo " INSTALAÇÃO FINALIZADA"
echo "===================================="
echo "Use: menu"
