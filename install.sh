#!/bin/bash

clear
echo "=== INSTALANDO NETSIMON PANEL (MODULAR) ==="

# -------------------------------
# VERIFICA ROOT
# -------------------------------
if [ "$EUID" -ne 0 ]; then
    echo "Execute como root!"
    exit 1
fi

# -------------------------------
# CORRIGIR POSSÍVEL CRLF
# -------------------------------
sed -i 's/\r$//' "$0" 2>/dev/null

# -------------------------------
# DEPENDÊNCIAS
# -------------------------------
echo "[+] Instalando dependências..."
apt-get update -y >/dev/null 2>&1
apt-get install -y curl wget unzip jq >/dev/null 2>&1

# -------------------------------
# ESTRUTURA
# -------------------------------
echo "[+] Criando estrutura..."
mkdir -p /etc/painel/{core,services,data}
mkdir -p /etc/xray-manager

# -------------------------------
# BASE URL
# -------------------------------
BASE_URL="https://raw.githubusercontent.com/miau4/PAINEL-NETSIMON/main"

# -------------------------------
# BAIXAR ARQUIVOS PRINCIPAIS
# -------------------------------
echo "[+] Baixando arquivos do painel..."

wget -q -O /etc/painel/menu.sh $BASE_URL/menu.sh
wget -q -O /etc/painel/config.json $BASE_URL/config.json

# -------------------------------
# BAIXAR SCRIPTS (CORE/SERVICES)
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
# BANCO DE DADOS
# -------------------------------
echo "[+] Criando base de dados..."
touch /etc/xray-manager/users.xray
touch /etc/xray-manager/blocked.db

# -------------------------------
# PERMISSÕES
# -------------------------------
echo "[+] Ajustando permissões..."
chmod -R +x /etc/painel

# -------------------------------
# COMANDO GLOBAL
# -------------------------------
echo "[+] Criando comando global..."
ln -sf /etc/painel/menu.sh /usr/local/bin/menu
chmod +x /usr/local/bin/menu

# -------------------------------
# TESTE REAL DO MENU
# -------------------------------
echo "[+] Testando menu..."

if bash /etc/painel/menu.sh; then
    echo "[OK] Menu funcionando!"
else
    echo "[ERRO] Menu com problema interno"
fi

# -------------------------------
# FINAL
# -------------------------------
clear
echo "===================================="
echo " INSTALAÇÃO CONCLUÍDA"
echo "===================================="
echo ""
echo "Digite: menu"
echo ""
