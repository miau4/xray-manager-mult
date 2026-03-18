```bash
#!/bin/bash

# ================= CORES =================
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
BLUE='\033[1;34m'
NC='\033[0m'

# ================= INFO VPS =================
IP=$(curl -s ifconfig.me)
OS=$(lsb_release -ds 2>/dev/null)
UPTIME=$(uptime -p | sed 's/up //')
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
RAM=$(free -m | awk '/Mem:/ {print $3"MB / "$2"MB"}')
DATE=$(date '+%d/%m/%Y %H:%M:%S')

# ================= HEADER =================
function header(){
clear
echo -e "${BLUE}==================================================${NC}"
echo -e "${CYAN}        NETSIMON - PAINEL DE CONTROLE${NC}"
echo -e "${BLUE}==================================================${NC}"

echo -e "${YELLOW}INFORMAÇÕES DA VPS${NC}"
echo -e " IP: $IP                SO: $OS"
echo -e " Uptime: $UPTIME        Hora: $DATE"
echo -e " CPU: $CPU%             Memória: $RAM"
echo -e "${BLUE}==================================================${NC}"
}

# ================= STATUS =================
function status_bar(){
XRAY=$(systemctl is-active xray 2>/dev/null)
SLOW=$(systemctl is-active slowdns-server 2>/dev/null)
WS=$(systemctl is-active nginx 2>/dev/null)

echo -e "${GREEN} XRAY: $XRAY | SLOWDNS: $SLOW | WEBSOCKET: $WS ${NC}"
echo -e "${BLUE}==================================================${NC}"
}

# ================= MENU =================
function menu(){
header
status_bar

echo -e "${CYAN}MENU${NC}"
echo ""
echo -e "[01] GERENCIAR USUÁRIOS        [08] FUNÇÕES EXTRAS"
echo -e "[02] GERENCIAR SSH             [09] TESTE VELOCIDADE"
echo -e "[03] GERENCIAR V2RAY           [10] OTIMIZAR VPS"
echo -e "[04] GERENCIAR XRAY            [11] INFO SISTEMA"
echo -e "[05] GERENCIAR SLOWDNS         [12] GERENCIAR BADVPN"
echo -e "[06] GERENCIAR WEBSOCKET       [13] BACKUP"
echo -e "[07] LIMITER USUÁRIOS          [14] SAIR"
echo ""

read -p "Digite a opção: " op

case $op in

1) echo "EM CONSTRUÇÃO" ;;
2) echo "EM CONSTRUÇÃO" ;;
3) bash /etc/painel/services/v2ray.sh ;;
4) menu_xray ;;
5) menu_slowdns ;;
6) menu_websocket ;;
7) echo "EM CONSTRUÇÃO" ;;

8) echo "EM CONSTRUÇÃO" ;;
9) bash /etc/painel/core/speedtest.sh ;;
10) apt update && apt upgrade -y ;;
11) bash /etc/painel/core/system.sh ;;
12) echo "EM CONSTRUÇÃO" ;;
13) echo "EM CONSTRUÇÃO" ;;
14) exit ;;

*) menu ;;
esac
}

# ================= XRAY =================
function menu_xray(){
clear
echo "=== XRAY ==="
echo "[1] Instalar / Reconfigurar"
echo "[2] Reiniciar"
echo "[3] Status"
echo "[0] Voltar"

read -p "Escolha: " op

case $op in
1) bash /etc/painel/services/xray.sh ;;
2) systemctl restart xray ;;
3) systemctl status xray ;;
0) menu ;;
esac
}

# ================= SLOWDNS =================
function menu_slowdns(){
clear
echo "=== SLOWDNS ==="
echo "[1] Instalar Servidor"
echo "[2] Ver chave"
echo "[3] Status"
echo "[4] Reiniciar"
echo "[0] Voltar"

read -p "Escolha: " op

case $op in
1) bash /etc/painel/services/slowdns-server.sh ;;
2) cat /etc/slowdns/public.key ;;
3) systemctl status slowdns-server ;;
4) systemctl restart slowdns-server ;;
0) menu ;;
esac
}

# ================= WEBSOCKET =================
function menu_websocket(){
clear
echo "=== WEBSOCKET (NGINX) ==="
echo "[1] Instalar WebSocket"
echo "[2] Configurar"
echo "[3] Reiniciar"
echo "[4] Status"
echo "[0] Voltar"

read -p "Escolha: " op

case $op in
1) bash /etc/painel/services/websocket.sh ;;
2) nano /etc/nginx/sites-enabled/ws.conf ;;
3) systemctl restart nginx ;;
4) systemctl status nginx ;;
0) menu ;;
esac
}

menu
```
