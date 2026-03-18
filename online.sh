```bash
#!/bin/bash

echo "=== ONLINE REAL (XRAY API) ==="

xray api statsquery --pattern "user>>>" 2>/dev/null | \
grep "online" | while read line; do

    user=$(echo $line | cut -d'>' -f3)
    status=$(echo $line | grep -o '[0-9]*$')

    if [ "$status" -gt 0 ]; then
        echo "$user - ONLINE ($status conexões)"
    fi

done
```
