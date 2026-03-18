```bash
#!/bin/bash

USERS="/etc/xray-manager/users.xray"
LOG="/var/log/xray/access.log"

while true; do

    NOW=$(date +%s)

    while IFS="|" read -r user uuid exp pass limit; do

        [[ -z "$limit" ]] && limit=1

        # pegar IPs dos últimos 60 segundos
        ips=$(grep "$user" $LOG | tail -n 100 | while read line; do
            log_time=$(echo "$line" | awk '{print $1" "$2}')
            log_ts=$(date -d "$log_time" +%s 2>/dev/null)

            diff=$((NOW - log_ts))

            if [ "$diff" -le 60 ]; then
                echo "$line" | awk '{print $3}' | cut -d: -f1
            fi
        done | sort | uniq)

        total=$(echo "$ips" | grep -c .)

        if [ "$total" -gt "$limit" ]; then
            echo "[$(date)] $user EXCEDEU ($total/$limit)"

            # 🔥 BLOQUEIO REAL
            iptables -A INPUT -s $(echo "$ips" | head -n1) -j DROP

        fi

    done < "$USERS"

    sleep 15
done
```
