#!/bin/bash

DB="/etc/xray-manager/exp.db"
USERS="/etc/xray-manager/users.xray"

mkdir -p /etc/xray-manager
[ ! -f "$DB" ] && touch "$DB"

read -p "Usuario: " user
read -p "Data de expiracao (AAAA-MM-DD): " date

# valida data
date -d "$date" >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Data inválida!"
    sleep 2
    exit
fi

# verifica se usuário existe
if ! grep -q "^$user|" "$USERS" 2>/dev/null; then
    echo "Usuário não encontrado!"
    sleep 2
    exit
fi

# salva registro
echo "$user|$date" >> "$DB"

echo "Expiracao registrada"
sleep 2
