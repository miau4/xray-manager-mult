```bash
#!/bin/bash

USERS="/etc/xray-manager/users.xray"
LOG="/var/log/xray/access.log"
BLOCKED="/etc/xray-manager/blocked.db"

touch $BLOCKED

echo "=== LIMITER XRAY (PRO) ==="

while true; do

    NOW=$(date +%s)

    while IFS="|" read -r user uuid exp pass limit; do

        [[ -z "$user" ]] && continue
        [[ -z "$limit" ]] && limit=1

        # ===============================
        # 🔥 VERIFICA SE JÁ ESTÁ BLOQUEADO
        # ===============================
        if grep -q "^$user|" "$BLOCKED"; then
            continue
        fi

        # ===============================
        # 🔥 CONEXÕES REAIS (API)
        # ===============================
        connections=$(xray api statsquery --pattern "user>>>$user>>>online" 2>/dev/null | grep -o '[0-9]*$')
        [[ -z "$connections" ]] && connections=0

        # ===============================
        # 🔥 IPs RECENTES (LOG + TEMPO REAL)
        # ===============================
        ips=$(grep "$user" $LOG | tail -n 100 | while read line; do
            log_time=$(echo "$line" | awk '{print $1" "$2}')
            log_ts=$(date -d "$log_time" +%s 2>/dev/null)

            diff=$((NOW - log_ts))

            if [ "$diff" -le 60 ]; then
                echo "$line" | awk '{print $3}' | cut -d: -f1
            fi
        done | sort | uniq)

        total_ips=$(echo "$ips" | grep -c .)

        # ===============================
        # 🔥 DEBUG (pode remover depois)
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
            jq --arg email "$user" '
            .inbounds[].settings.clients |= map(select(.email != $email))
            ' /etc/xray/config.json > /tmp/config.json && mv /tmp/config.json /etc/xray/config.json

            systemctl restart xray

            # ===============================
            # 🔥 REGISTRAR BLOQUEIO COM TEMPO
            # ===============================
            echo "$user|$NOW" >> $BLOCKED

            echo "🔒 $user BLOQUEADO COM SUCESSO"

        fi

    done < "$USERS"

    sleep 15

done
```
