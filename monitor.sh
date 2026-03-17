#!/bin/bash

CONFIG="/etc/xray/config.json"

while true; do
    clear
    echo "════════ MONITOR XRAY ════════"
    echo "1) Usuários online"
    echo "2) Derrubar usuário"
    echo "3) Voltar"
    echo "══════════════════════════════"

    read -p "Escolha: " op

    case $op in
        1)
            echo "Usuários conectados:"
            xray api statsquery --pattern "user>>>*" 2>/dev/null | grep "online"
            read -p "Enter..."
            ;;
        2)
            read -p "Nome do usuário: " user
            xray api statsquery --reset --pattern "user>>>$user>>>*" 2>/dev/null
            echo "Usuário derrubado!"
            sleep 2
            ;;
        3) break ;;
    esac
done
