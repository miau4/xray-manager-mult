#!/bin/bash
clear

# ----------------- CORES -----------------
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'
NC='\033[0m'

CONFIG="/etc/xray/config.json"
USERS="/etc/xray-manager/users.xray"
API="/etc/xray-manager/api.sh"

# ----------------- MENU PRINCIPAL -----------------
main_menu() {
    while true; do
        clear
        echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}        ⚡ NETSIMON MANAGER ⚡              ${NC}"
        echo -e "${BLUE}╠════════════════════════════════════════════╣${NC}"
        echo -e "${GREEN} 1) Usuários${NC}"
        echo -e "${GREEN} 2) Conexões${NC}"
        echo -e "${GREEN} 3) Monitor Online${NC}"
        echo -e "${GREEN} 4) API (info)${NC}"
        echo -e "${RED} 0) Sair${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
        read -p "Escolha: " opt

        case $opt in
            1) users_menu ;;
            2) conexoes_menu ;;
            3) monitor_online ;;
            4) api_menu ;;
            0) exit ;;
            *) echo "Inválido"; sleep 1 ;;
        esac
    done
}

# ----------------- USUÁRIOS -----------------
users_menu() {
    while true; do
        clear
        echo -e "${BLUE}══════ USUÁRIOS ══════${NC}"
        echo "1) Adicionar"
        echo "2) Remover"
        echo "3) Listar"
        echo "0) Voltar"
        read -p "Escolha: " op

        case $op in
            1) adduser ;;
            2) deluser ;;
            3) listar_usuarios ;;
            0) break ;;
        esac
    done
}

listar_usuarios() {
    clear
    echo -e "${CYAN}Usuários cadastrados:${NC}"
    nl -w2 -s') ' $USERS 2>/dev/null || echo "Nenhum usuário."
    read -p "Enter..."
}

# ----------------- DELUSER PROFISSIONAL -----------------
deluser() {
    clear

    [ ! -f "$USERS" ] && echo "Nenhum usuário." && sleep 2 && return

    echo -e "${CYAN}Selecione o usuário:${NC}"
    mapfile -t lista < <(cut -d'|' -f1 "$USERS")

    for i in "${!lista[@]}"; do
        echo "$((i+1))) ${lista[$i]}"
    done

    read -p "Número: " num

    if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt "${#lista[@]}" ]; then
        echo -e "${RED}Inválido${NC}"
        sleep 2
        return
    fi

    user="${lista[$((num-1))]}"
    uuid=$(grep "^$user|" "$USERS" | cut -d'|' -f2)

    grep -v "^$user|" "$USERS" > /tmp/users.tmp && mv /tmp/users.tmp "$USERS"

    jq --arg uuid "$uuid" '
    (.inbounds[] | select(.protocol=="vless" or .protocol=="vmess") | .settings.clients)
    |= map(select(.id != $uuid))
    ' "$CONFIG" > /tmp/config.json && mv /tmp/config.json "$CONFIG"

    systemctl restart xray

    echo -e "${GREEN}Usuário removido!${NC}"
    sleep 2
}

# ----------------- CONEXÕES -----------------
conexoes_menu() {
    while true; do
        clear
        echo -e "${BLUE}══════ CONEXÕES ══════${NC}"
        echo "1) Reiniciar Xray"
        echo "2) WebSocket"
        echo "3) SlowDNS"
        echo "0) Voltar"

        read -p "Escolha: " op

        case $op in
            1)
                systemctl restart xray
                echo "Reiniciado!"
                sleep 2
                ;;
            2) websocket_menu ;;
            3) slowdns_menu ;;
            0) break ;;
        esac
    done
}

# ----------------- WEBSOCKET -----------------
websocket_menu() {
    clear
    read -p "Nova porta WS: " porta

    jq ".inbounds[] |= if .tag==\"vless-ws\" then .port=$porta else . end" $CONFIG > /tmp/config.json
    mv /tmp/config.json $CONFIG

    systemctl restart xray

    echo -e "${GREEN}WebSocket na porta $porta${NC}"
    sleep 2
}

# ----------------- SLOWDNS -----------------
slowdns_menu() {
    clear
    [ ! -f /usr/local/bin/slowdns ] && bash <(curl -sL https://raw.githubusercontent.com/miau4/xray-manager-mult-slowdns/main/install.sh)
    bash /usr/local/bin/slowdns
}

# ----------------- MONITOR ONLINE -----------------
monitor_online() {
    clear
    echo -e "${CYAN}Usuários online:${NC}"
    xray api statsquery --pattern "user>>>*" 2>/dev/null | grep online
    echo ""
    read -p "Enter..."
}

# ----------------- API MENU -----------------
api_menu() {
    while true; do
        clear
        echo -e "${BLUE}══════ API ══════${NC}"
        echo "1) Listar usuários (JSON)"
        echo "2) IPs de usuário"
        echo "3) Derrubar usuário"
        echo "0) Voltar"

        read -p "Escolha: " op

        case $op in
            1) $API list | jq .; read -p "Enter..." ;;
            2)
                read -p "Usuário: " user
                $API ips $user
                read -p "Enter..."
                ;;
            3)
                read -p "Usuário: " user
                $API drop $user
                sleep 2
                ;;
            0) break ;;
        esac
    done
}

# ----------------- AUTO START -----------------
PROFILE_FILE="$HOME/.bash_profile"
[ ! -f "$PROFILE_FILE" ] && PROFILE_FILE="$HOME/.profile"
grep -qxF "main_menu" $PROFILE_FILE || echo "main_menu" >> $PROFILE_FILE

main_menu
