#!/bin/bash

# Demo skrypt dla modułu USER
# Pokazuje różne sposoby tworzenia użytkowników

set -e

echo "=== DEMO MODUŁ USER ==="
echo

# Kolory
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

demo_cmd() {
    echo -e "${BLUE}Komenda: $1${NC}"
    echo "Opis: $2"
    echo "---"
    echo
}

echo "Oto przykłady użycia modułu USER:"
echo

demo_cmd "./run-automation.sh user -e \"user=jan home=default\"" \
         "Tworzy użytkownika 'jan' z katalogiem /home/jan"

demo_cmd "./run-automation.sh user -e \"user=tomcat home=/opt/tomcat\"" \
         "Tworzy użytkownika 'tomcat' z katalogiem /opt/tomcat"

demo_cmd "./run-automation.sh user -e \"user=admin home=default sudo=true\"" \
         "Tworzy administratora z uprawnieniami sudo"

demo_cmd "./run-automation.sh user -e \"user=webuser home=webuser groups=www-data\"" \
         "Tworzy użytkownika webuser w grupie www-data"

demo_cmd "./run-automation.sh user -e \"user=developer home=default ssh_key='ssh-rsa AAAA...'\"" \
         "Tworzy użytkownika z kluczem SSH"

echo -e "${GREEN}Aby uruchomić któryś z przykładów, skopiuj komendę i wykonaj.${NC}"
echo -e "${GREEN}Pamiętaj o dostosowaniu inventory do swoich hostów!${NC}"
echo
echo "Więcej informacji: docs/USER-MODULE.md"