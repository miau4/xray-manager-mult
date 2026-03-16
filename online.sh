#!/bin/bash
USERS="/etc/xray-manager/users.xray"

if [ ! -f "$USERS" ] || [ ! -s "$USERS" ]; then
    echo "Nenhum usuário cadastrado."
    exit 1
fi

echo -e "Usuários online/offline:"

# Criar arrays
online_list=()
offline_list=()

while IFS=: read -r name pass uuid exp; do
    if grep -q "$uuid" /var/log/xray/access.log; then
        online_list+=("$name - Online - UUID: $uuid - Expira: $exp")
    else
        offline_list+=("$name - Offline - UUID: $uuid - Expira: $exp")
    fi
done < "$USERS"

# Mostrar primeiro online, depois offline
for u in "${online_list[@]}"; do
    echo -e "$u"
done
for u in "${offline_list[@]}"; do
    echo -e "$u"
done
