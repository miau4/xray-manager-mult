#!/bin/bash

clear

STATUS=$(ps aux | grep slowdns | grep -v grep)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "     GERENCIADOR SLOWDNS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ ! -z "$STATUS" ]; then
PORT=$(cat /etc/slowdns/port 2>/dev/null)
PID=$(pgrep slowdns)

echo "Status: ATIVO"
echo "PID: $PID"
echo "Porta: $PORT"
else
echo "Status: PARADO"
fi

echo ""
echo "1 • Instalar SlowDNS"
echo "2 • Desinstalar SlowDNS"
echo "3 • Ver informações"
echo "0 • Voltar"
echo ""

read -p "Escolha: " op

case $op in

1)
bash <(curl -Ls https://raw.githubusercontent.com/fisabiliyusri/slowdns/master/install.sh)
;;

2)
systemctl stop slowdns 2>/dev/null
rm -rf /etc/slowdns
rm -f /usr/bin/slowdns
echo "SlowDNS removido"
;;

3)
echo ""
echo "Processos:"
ps aux | grep slowdns
;;

0)
menu
;;

esac
