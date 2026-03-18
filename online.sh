```bash
#!/bin/bash

echo "=============================="
echo "   USUÁRIOS ONLINE (REAL)"
echo "=============================="
echo ""

# Consulta API do Xray
xray api statsquery --pattern "user>>>" 2>/dev/null | while read line; do

    user=$(echo "$line" | cut -d'>' -f3)
    value=$(echo "$line" | grep -o '[0-9]*$')

    # apenas usuários com conexão ativa
    if [[ "$value" -gt 0 ]]; then
        echo "$user - ONLINE ($value conexões)"
    fi

done

echo ""
```
