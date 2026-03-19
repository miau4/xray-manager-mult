#!/bin/bash

echo "=============================="
echo "   USUÁRIOS ONLINE (REAL)"
echo "=============================="
echo ""

# verificar se xray existe
if ! command -v xray >/dev/null 2>&1; then
    echo "Xray não instalado!"
    echo ""
    exit
fi

# consulta API do Xray
xray api statsquery --pattern "user>>>" 2>/dev/null | while read -r line; do

    # extrair usuário com segurança
    user=$(echo "$line" | awk -F '>>>' '{print $2}' | awk -F '>' '{print $1}')
    
    # extrair valor numérico final
    value=$(echo "$line" | grep -o '[0-9]*$')

    # garantir que value é número
    if [[ -z "$value" || ! "$value" =~ ^[0-9]+$ ]]; then
        continue
    fi

    # apenas usuários com conexão ativa
    if [[ "$value" -gt 0 ]]; then
        echo "$user - ONLINE ($value conexões)"
    fi

done

echo ""
