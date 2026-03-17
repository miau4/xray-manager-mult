#!/bin/bash

USERS="/etc/xray-manager/users.xray"

case "$1" in

list)
    echo "["
    while IFS="|" read -r user uuid exp pass limit; do
        echo "  {\"user\":\"$user\",\"uuid\":\"$uuid\",\"exp\":\"$exp\",\"limit\":\"$limit\"},"
    done < "$USERS" | sed '$ s/,$//'
    echo "]"
;;

online)
    xray api statsquery --pattern "user>>>*" 2>/dev/null | grep "online"
;;

drop)
    user="$2"
    xray api statsquery --reset --pattern "user>>>$user>>>*" 2>/dev/null
    echo "Usuário derrubado"
;;

ips)
    user="$2"
    grep "$user" /var/log/xray/access.log | tail -n 50 | awk '{print $3}' | cut -d: -f1 | sort | uniq
;;

*)
    echo "Uso:"
    echo "api.sh list"
    echo "api.sh online"
    echo "api.sh drop usuario"
    echo "api.sh ips usuario"
;;

esac
