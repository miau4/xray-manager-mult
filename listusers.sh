#!/bin/bash
USERS="/etc/xray-manager/users.xray"

if [ ! -f "$USERS" ] || [ ! -s "$USERS" ]; then
    echo "Nenhum usuário cadastrado."
    exit 1
fi

echo "Lista de usuários cadastrados:"
printf "%-20s %-10s %-36s %-12s\n" "NOME" "SENHA" "UUID" "EXPIRA"
while IFS=: read -r name pass uuid exp; do
    printf "%-20s %-10s %-36s %-12s\n" "$name" "$pass" "$uuid" "$exp"
done < $USERS
