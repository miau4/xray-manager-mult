#!/bin/bash

CONFIG="/etc/xray/config.json"
USERS="/etc/xray-manager/users.xray"

read -p "Nome do usuario a remover: " user

if ! grep -q "^$user:" $USERS; then
    echo "Usuário não encontrado!"
    exit 1
fi

# Pegar UUID
UUID=$(grep "^$user:" $USERS | cut -d: -f2)

# Remover de todos os inbounds
jq "(.inbounds[].settings.clients) |= map(select(.id != \"$UUID\"))" $CONFIG > /tmp/config.json
mv /tmp/config.json $CONFIG

# Remover do arquivo de usuários
grep -v "^$user:" $USERS > /tmp/users.tmp
mv /tmp/users.tmp $USERS

# Reiniciar Xray
systemctl restart xray

echo "Usuário $user removido com sucesso."
