#!/bin/bash
# Menu SlowDNS Manager integrado ao Xray-Manager-Mult
clear
SLOWDNS_DIR="/etc/slowdns"

slowdns_menu() {
    clear
    echo -e "\033[1;31m════════════════════════════════════════════════════\033[0m"
    tput setaf 7 ; tput setab 4 ; tput bold ; printf '%40s%s%-12s\n' "MENU SLOWDNS MANAGER INTEGRADO" ; tput sgr0
    echo -e "\033[1;31m════════════════════════════════════════════════════\033[0m"
    echo ""
    echo -e "\033[0;36m[01]\033[m | Instalar SlowDNS"
    echo -e "\033[0;36m[02]\033[m | Informações do serviço"
    echo -e "\033[0;36m[03]\033[m | Iniciar SlowDNS"
    echo -e "\033[0;36m[04]\033[m | Parar SlowDNS"
    echo -e "\033[0;36m[05]\033[m | Reiniciar SlowDNS"
    echo -e "\033[0;36m[06]\033[m | Remover SlowDNS"
    echo -e "\033[0;36m[00]\033[m | Voltar ao menu principal"
    echo ""
    echo -ne "\033[0;36mEscolha: \033[0m" && read opcao

    case $opcao in
        1) bash $SLOWDNS_DIR/install ;;
        2) bash $SLOWDNS_DIR/slowdns-info ;;
        3) bash $SLOWDNS_DIR/startdns ;;
        4) bash $SLOWDNS_DIR/stopdns ;;
        5) bash $SLOWDNS_DIR/restartdns ;;
        6) bash $SLOWDNS_DIR/remove-slow ;;
        0) exit 0 ;;
        *) echo -e "\033[1;31mOpção inválida!\033[0m"; sleep 1; slowdns_menu ;;
    esac
}
slowdns_menu
