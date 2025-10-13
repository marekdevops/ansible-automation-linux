#!/bin/bash

# Demo skrypt - praca z różnymi plikami inventory
# Pokazuje jak używać różnych środowisk

set -e

echo "=== DEMO: PRACA Z RÓŻNYMI INVENTORY ==="
echo

# Kolory
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_env() {
    echo -e "${CYAN}=== $1 ===${NC}"
}

print_cmd() {
    echo -e "${BLUE}Komenda:${NC} $1"
}

print_desc() {
    echo -e "${YELLOW}Opis:${NC} $1"
}

# Sprawdź dostępne pliki inventory
echo -e "${GREEN}📁 DOSTĘPNE PLIKI INVENTORY:${NC}"
echo
for file in inventory/*.yml; do
    if [[ -f "$file" ]]; then
        basename "$file"
    fi
done
echo

# PRZYKŁADY UŻYCIA
print_env "PRODUKCJA (inventory/production.yml)"
print_cmd "./run-automation.sh -i inventory/production.yml user -e \"user=webmaster\""
print_desc "Tworzy użytkownika w środowisku produkcyjnym (bezpieczne ustawienia)"
echo

print_cmd "./run-automation.sh -i inventory/production.yml sudoers -e \"user=webmaster commands_file=webmaster_commands\""
print_desc "Konfiguruje sudo dla webmastera w produkcji"
echo

print_env "STAGING (inventory/staging.yml)"
print_cmd "./run-automation.sh -i inventory/staging.yml user -e \"user=tester home=default sudo=true\""
print_desc "Tworzy testera w staging (mniej restrykcyjne ustawienia)"
echo

print_cmd "./run-automation.sh -i inventory/staging.yml -t update -e \"reboot_after_update=true\""
print_desc "Aktualizacja z restartem (w staging można restartować)"
echo

print_env "DEVELOPMENT (inventory/development.yml)"
print_cmd "./run-automation.sh -i inventory/development.yml user -e \"user=developer home=default sudo=true\""
print_desc "Tworzy developera (maksymalna swoboda)"
echo

print_cmd "./run-automation.sh -i inventory/development.yml -e \"install_dev_tools=true install_docker=true\""
print_desc "Instaluje narzędzia deweloperskie"
echo

print_env "LOCALHOST (inventory/localhost.yml)"
print_cmd "./run-automation.sh -i inventory/localhost.yml user -e \"user=testuser\" -c"
print_desc "Bezpieczny test na localhost (dry-run)"
echo

print_env "OGRANICZENIA DO HOSTÓW"
print_cmd "./run-automation.sh -i inventory/production.yml -l webservers user -e \"user=webadmin\""
print_desc "Tylko na webserverach w produkcji"
echo

print_cmd "./run-automation.sh -i inventory/production.yml -l prod-web01 sudoers -e \"user=webadmin\""
print_desc "Tylko na konkretnym hoście"
echo

echo -e "${GREEN}🔧 WORKFLOW TESTOWANIA:${NC}"
echo "1. Test lokalny:     ./run-automation.sh -i inventory/localhost.yml [komenda] -c"
echo "2. Test staging:     ./run-automation.sh -i inventory/staging.yml [komenda] -c"  
echo "3. Uruchom staging:  ./run-automation.sh -i inventory/staging.yml [komenda]"
echo "4. Test produkcja:   ./run-automation.sh -i inventory/production.yml [komenda] -c"
echo "5. Uruchom produkcja: ./run-automation.sh -i inventory/production.yml [komenda]"
echo

echo -e "${GREEN}📖 Więcej informacji: docs/INVENTORY-USAGE.md${NC}"