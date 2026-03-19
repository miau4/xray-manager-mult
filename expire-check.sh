#!/bin/bash

USERS="/etc/xray-manager/users.xray"

echo "Status de expiração dos usuários:"
echo ""

[ ! -f "$USERS" ] && echo "Arquivo não encontrado!" && exit

while IFS="|" read -r name uuid exp pass limit; do

    [[ -z "$name" ]] && continue

    exp_ts=$(date -d "$exp" +%s 2>/dev/null)
    now_ts=$(date +%s)

    if [[ -z "$exp_ts" ]]; then
        status="Data inválida"
    elif [[ "$exp_ts" -lt "$now_ts" ]]; then
        status="Expirado"
    else
        status="Válido"
    fi

    echo "$name - $status - Expira em: $exp"

done < "$USERS"

echo ""
read -n1 -r -p "Pressione qualquer tecla..."
