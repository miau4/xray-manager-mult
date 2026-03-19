#!/bin/bash

USERS="/etc/xray-manager/users.xray"
LOG="/var/log/xray/access.log"
BLOCKED="/etc/xray-manager/blocked.db"
CONFIG="/etc/xray/config.json"

mkdir -p /etc/xray-manager
[ ! -f "$USERS" ] && touch "$USERS"
[ ! -f "$BLOCKED" ] && touch "$BLOCKED"

echo "=== LIMITER XRAY (PRO) ==="

# verifica xray
if ! command -v xray >/dev/null 2>&1; then
    echo "Xray não encontrado!"
    exit
fi

while true; do

    NOW=$(date +%s)

    while IFS="|" read -r user uuid exp pass limit; do

        [[ -z "$user" ]] && continue
        [[ ! "$limit" =~ ^[0-9]+$ ]] && limit=1

        # ===============================
        # 🔥 VERIFICA SE JÁ ESTÁ BLOQUEADO
        # ===============================
        if grep -q "^$user|" "$BLOCKED" 2>/dev/null; then
            continue
        fi

        # ===============================
        # 🔥 CONEXÕES REAIS (API)
        # ===============================
        connections=$(xray api statsquery --pattern "user>>>$user>>>online" 2>/dev/null | grep -o '[0-9]*$')
        [[ ! "$connections" =~ ^[0-9]+$ ]] && connections=0

        # ===============================
        # 🔥 IPs RECENTES (LOG)
        # ===============================
        total_ips=0

        if [ -f "$LOG" ]; then
            ips=$(grep "$user" "$LOG" 2>/dev/null | tail -n 100 | while read -r line; do

                log_time=$(echo "$line" | awk '{print $1" "$2}')
                log_ts=$(date -d "$log_time" +%s 2>/dev/null)

                [[ -z "$log_ts" ]] && continue

                diff=$((NOW - log_ts))

                if [ "$diff" -le 60 ]; then
                    echo "$line" | awk '{print $3}' | cut -d: -f1
                fi

            done | sort | uniq)

            total_ips=$(echo "$ips" | grep -c .)
        fi

        # ===============================
        # 🔥 DEBUG
        # ===============================
        echo "[$(date)] $user -> conexões=$connections / ips=$total_ips / limite=$limit"

        # ===============================
        # 🔥 VERIFICA LIMITE
        # ===============================
        if [ "$connections" -gt "$limit" ] || [ "$total_ips" -gt "$limit" ]; then

            echo "🚫 $user EXCEDEU LIMITE!"

            # ===============================
            # 🔥 REMOVER DO XRAY (BLOQUEIO REAL)
            # ===============================
            if [ -f "$CONFIG" ]; then

                command -v jq >/dev/null 2>&1
                if [ $? -eq 0 ]; then

                    tmp=$(mktemp)

                    jq --arg email "$user" '
                    .inbounds[].settings.clients |= map(select(.email != $email))
                    ' "$CONFIG" > "$tmp"

                    if [ $? -eq 0 ] && [ -s "$tmp" ]; then
                        mv "$tmp" "$CONFIG"
                        systemctl restart xray 2>/dev/null
                    else
                        echo "Erro ao atualizar config.json"
                        rm -f "$tmp"
                    fi

                else
                    echo "jq não instalado! não foi possível bloquear no Xray"
                fi

            fi

            # ===============================
            # 🔥 REGISTRAR BLOQUEIO
            # ===============================
            echo "$user|$NOW" >> "$BLOCKED"

            echo "🔒 $user BLOQUEADO COM SUCESSO"

        fi

    done < "$USERS"

    sleep 15

done
