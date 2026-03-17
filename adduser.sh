#!/bin/bash

USERS="/etc/xray-manager/users.xray"
CONFIG="/etc/xray/config.json"

clear
echo "══════════════════════════════"
echo "     ➕ CRIAR USUÁRIO PRO"
echo "══════════════════════════════"

# ----------------- INPUT -----------------
read -p "Nome do usuário: " user

if [[ -z "$user" || "$user" =~ [^a-zA-Z0-9_] ]]; then
    echo "Nome inválido! (use apenas letras/números)"
    sleep 2
    exit
fi

if grep -q "^$user|" "$USERS" 2>/dev/null; then
    echo "Usuário já existe!"
    sleep 2
    exit
fi

read -p "Senha: " pass
[ -z "$pass" ] && echo "Senha inválida!" && sleep 2 && exit

read -p "Dias de validade: " dias
[[ ! "$dias" =~ ^[0-9]+$ ]] && echo "Valor inválido!" && sleep 2 && exit

# 🔐 limite de conexões
read -p "Limite de IPs simultâneos (ex: 1,2,3): " limit
[[ ! "$limit" =~ ^[0-9]+$ ]] && limit=1

# ----------------- GERAR -----------------
uuid=$(uuidgen)
exp_date=$(date -d "+$dias days" +"%Y-%m-%d")

# ----------------- CONFIRMAÇÃO -----------------
clear
echo "════════ CONFIRMAÇÃO ════════"
echo "Usuário : $user"
echo "Senha   : $pass"
echo "UUID    : $uuid"
echo "Validade: $exp_date"
echo "Limite  : $limit IP(s)"
echo "═════════════════════════════"
read -p "Confirmar? (s/n): " confirm

[[ "$confirm" != "s" && "$confirm" != "S" ]] && exit

# ----------------- SALVAR -----------------
mkdir -p /etc/xray-manager

# formato sem horário agora
echo "$user|$uuid|$exp_date|$pass|$limit" >> $USERS

# ----------------- XRAY CONFIG -----------------
if [ -f "$CONFIG" ]; then
    tmp=$(mktemp)

    jq --arg uuid "$uuid" --arg user "$user" '
    (.inbounds[] | select(.protocol=="vless" or .protocol=="vmess") | .settings.clients) += [{
        "id": $uuid,
        "email": $user
    }]
    ' "$CONFIG" > "$tmp" && mv "$tmp" "$CONFIG"

    systemctl restart xray
fi

# ----------------- RESULTADO -----------------
clear
echo "══════════════════════════════"
echo "     ✅ USUÁRIO CRIADO"
echo "══════════════════════════════"
echo "Usuário : $user"
echo "Senha   : $pass"
echo "UUID    : $uuid"
echo "Expira  : $exp_date"
echo "Limite  : $limit IP(s)"
echo "══════════════════════════════"

read -n1 -r -p "Pressione qualquer tecla..."
