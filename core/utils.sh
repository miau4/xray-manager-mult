
```bash
#!/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

function msg(){
echo -e "${GREEN}$1${NC}"
}

function error(){
echo -e "${RED}$1${NC}"
}
```
