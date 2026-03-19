#!/bin/bash

REPO="https://raw.githubusercontent.com/miau4/PAINEL-NETSIMON/main"

echo "Atualizando XRAY MANAGER..."

curl -o /usr/local/bin/menu $REPO/menu.sh
curl -o /usr/local/bin/adduser $REPO/adduser.sh
curl -o /usr/local/bin/deluser $REPO/deluser.sh
curl -o /usr/local/bin/online $REPO/online.sh
curl -o /usr/local/bin/rebuild $REPO/rebuild.sh
curl -o /usr/local/bin/limit $REPO/limit.sh
curl -o /usr/local/bin/expire $REPO/expire.sh
curl -o /usr/local/bin/backup $REPO/backup.sh
curl -o /usr/local/bin/checkjson $REPO/checkjson.sh
curl -o /usr/local/bin/limit-monitor $REPO/limit-monitor.sh
curl -o /usr/local/bin/expire-check $REPO/expire-check.sh

chmod +x /usr/local/bin/*

echo "Atualização concluída"
