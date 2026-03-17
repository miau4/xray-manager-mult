#!/bin/bash
clear

# ----------------- CORES -----------------
RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
LILAC='\033[1;35m'
NC='\033[0m'

# ----------------- CONFIG -----------------
CONFIG="/etc/xray-manager/slowdns.conf"

# ----------------- FUNÇÕES -----------------
menu_slowdns() {
    while true; do
        clear
        echo -e "${LILAC}╔════════════════════════════╗${NC}"
        echo -e "${CYAN}      █ S L O W D N S █       ${NC}"
        echo -e "${LILAC}╠════════════════════════════╣${NC}"
        echo -e "${LILAC}1) Instalar SlowDNS${NC}"
        echo -e "${LILAC}2) Reiniciar SlowDNS${NC}"
        echo -e "${LILAC}3) Parar SlowDNS${NC}"
        echo -e "${LILAC}4) Status SlowDNS${NC}"
        echo -e "${LILAC}0) Voltar${NC}"
        echo -e "${LILAC}╚════════════════════════════╝${NC}"
        read -p "Escolha: " sd
        case $sd in
            1)
                bash <(curl -Ls https://raw.githubusercontent.com/miau4/xray-manager-mult/main/install-slowdns.sh)
                sleep 2
                ;;
            2)
                systemctl restart slowdns >/dev/null 2>&1
                echo -e "${GREEN}SlowDNS reiniciado com sucesso${NC}"
                sleep 2
                ;;
            3)
                systemctl stop slowdns >/dev/null 2>&1
                echo -e "${RED}SlowDNS parado${NC}"
                sleep 2
                ;;
            4)
                status=$(systemctl is-active slowdns)
                if [ "$status" = "active" ]; then
                    echo -e "${GREEN}SlowDNS ATIVO${NC}"
                else
                    echo -e "${RED}SlowDNS INATIVO${NC}"
                fi
                sleep 2
                ;;
            0)
                break
                ;;
            *)
                echo -e "${RED}Opção inválida!${NC}"
                sleep 1
                ;;
        esac
    done
}

# ----------------- INICIAR MENU -----------------
menu_slowdns
