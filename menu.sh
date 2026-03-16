#!/bin/bash

export PATH=$PATH:/usr/local/bin

CONFIG="/etc/xray/config.json"
USERDB="/etc/xray-manager/users.db"
LOG="/var/log/xray/access.log"

clear

RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

IP=$(curl -s ifconfig.me)

CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
RAM=$(free -m | awk '/Mem:/ {print $3"MB / "$2"MB"}')
UPTIME=$(uptime -p)

TOTAL_USERS=$(cat $USERDB 2>/dev/null | wc -l)
ONLINE_USERS=$(grep accepted $LOG 2>/dev/null | wc -l)

XRAY_STATUS=$(systemctl is-active xray 2>/dev/null)
BADVPN_STATUS=$(systemctl is-active badvpn 2>/dev/null)

if pgrep slowdns > /dev/null
then
SLOWDNS_STATUS="ativo"
else
SLOWDNS_STATUS="parado"
fi

echo -e "${CYAN}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "        XRAY MANAGER MULT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${NC}"

echo -e "${GREEN}Servidor${NC}"
echo "IP: $IP"
echo "Uptime: $UPTIME"
echo "CPU: $CPU%"
echo "RAM: $RAM"

echo ""

echo -e "${GREEN}Serviços${NC}"
echo "Xray: $XRAY_STATUS"
echo "BadVPN: $BADVPN_STATUS"
echo "SlowDNS: $SLOWDNS_STATUS"

echo ""

echo -e "${GREEN}Usuários${NC}"
echo "Total: $TOTAL_USERS"
echo "Online: $ONLINE_USERS"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "1  • Criar usuario VLESS"
echo "2  • Remover usuario"
echo "3  • Usuarios online"
echo "4  • Definir limite"
echo "5  • Definir expiração"
echo "6  • Backup config"
echo "7  • Rebuild config"
echo "8  • Verificar JSON"

echo ""

echo "9  • Teste de velocidade"
echo "10 • Gerenciador SSH"
echo "11 • Gerenciador SlowDNS"

echo ""

echo "12 • Atualizar script"
echo "13 • Remover script"

echo ""

echo "0  • Sair"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

read -p "Escolha: " op

case $op in

1)
/usr/local/bin/adduser
;;

2)
/usr/local/bin/deluser
;;

3)
/usr/local/bin/online
;;

4)
/usr/local/bin/limit
;;

5)
/usr/local/bin/expire
;;

6)
/usr/local/bin/backup
;;

7)
/usr/local/bin/rebuild
;;

8)
/usr/local/bin/checkjson
;;

9)
/usr/local/bin/speedtest
;;

10)
/usr/local/bin/ssh-manager
;;

11)
/usr/local/bin/slowdns
;;

12)
/usr/local/bin/update-xray
;;

13)
/usr/local/bin/uninstall-xray
;;

0)
exit
;;

*)
echo "Opção inválida"
;;

esac

echo ""
read -p "Pressione ENTER para voltar ao menu"

menu
