#!/bin/bash

# Kompletny przykład workflow z różnymi inventory
# Pokazuje jak przejść przez wszystkie środowiska

set -e

echo "=== KOMPLETNY WORKFLOW: USER + SUDOERS W RÓŻNYCH ŚRODOWISKACH ==="
echo

# Kolory
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

print_step() {
    echo -e "${CYAN}KROK $1:${NC} $2"
}

print_env() {
    echo -e "${YELLOW}=== $1 ===${NC}"
}

print_cmd() {
    echo -e "${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

echo "Ten przykład pokazuje jak utworzyć użytkownika 'webmaster'"
echo "i skonfigurować dla niego sudo w różnych środowiskach."
echo

# LOCALHOST - TEST
print_env "1. TESTY LOKALNE (LOCALHOST)"
print_step "1.1" "Test tworzenia użytkownika (dry-run)"
print_cmd "./run-automation.sh -i inventory/localhost.yml user -e \"user=webmaster home=default\" -c"
echo

print_step "1.2" "Test konfiguracji sudo (dry-run)"
print_cmd "./run-automation.sh -i inventory/localhost.yml sudoers -e \"user=webmaster commands_file=webmaster_commands\" -c"
echo

print_success "Testy lokalne OK - można przejść do staging"
echo

# STAGING
print_env "2. ŚRODOWISKO TESTOWE (STAGING)"
print_step "2.1" "Tworzenie użytkownika w staging (dry-run)"
print_cmd "./run-automation.sh -i inventory/staging.yml user -e \"user=webmaster home=default\" -c"
echo

print_step "2.2" "Jeśli OK, wykonanie w staging"
print_cmd "./run-automation.sh -i inventory/staging.yml user -e \"user=webmaster home=default\""
echo

print_step "2.3" "Konfiguracja sudo w staging"
print_cmd "./run-automation.sh -i inventory/staging.yml sudoers -e \"user=webmaster commands_file=webmaster_commands\""
echo

print_step "2.4" "Test uprawnień w staging"
print_cmd "# Zaloguj się na staging i sprawdź:"
print_cmd "# sudo -l -U webmaster"
echo

print_success "Staging OK - można przejść do produkcji"
echo

# PRODUCTION
print_env "3. ŚRODOWISKO PRODUKCYJNE (PRODUCTION)"
print_step "3.1" "Test w produkcji (dry-run) - ZAWSZE!"
print_cmd "./run-automation.sh -i inventory/production.yml user -e \"user=webmaster home=default\" -c"
echo

print_step "3.2" "Jeśli test OK, wykonanie w produkcji"
print_cmd "./run-automation.sh -i inventory/production.yml user -e \"user=webmaster home=default\""
echo

print_step "3.3" "Konfiguracja sudo w produkcji"
print_cmd "./run-automation.sh -i inventory/production.yml sudoers -e \"user=webmaster commands_file=webmaster_commands\""
echo

print_step "3.4" "Weryfikacja w produkcji"
print_cmd "# Sprawdź pliki sudoers:"
print_cmd "# sudo ls -la /etc/sudoers.d/"
print_cmd "# sudo -l -U webmaster"
echo

print_success "Produkcja skonfigurowana!"
echo

# DODATKOWE PRZYKŁADY
print_env "4. DODATKOWE PRZYKŁADY"

echo "🔧 Różne role w różnych środowiskach:"
echo

print_step "4.1" "Docker Admin w development"
print_cmd "./run-automation.sh -i inventory/development.yml user -e \"user=dockeradmin home=default sudo=true\""
print_cmd "./run-automation.sh -i inventory/development.yml sudoers -e \"user=dockeradmin commands_file=docker_commands\""
echo

print_step "4.2" "Backup Operator w produkcji"
print_cmd "./run-automation.sh -i inventory/production.yml user -e \"user=backup home=/backup\""
print_cmd "./run-automation.sh -i inventory/production.yml sudoers -e \"user=backup commands_file=backup_commands\""
echo

print_step "4.3" "Ograniczenie do konkretnych hostów"
print_cmd "./run-automation.sh -i inventory/production.yml -l webservers user -e \"user=webadmin\""
print_cmd "./run-automation.sh -i inventory/production.yml -l prod-web01 sudoers -e \"user=webadmin\""
echo

echo -e "${GREEN}🎯 NAJLEPSZE PRAKTYKI:${NC}"
echo "1. Zawsze testuj z -c (dry-run) przed wykonaniem"
echo "2. Testuj na localhost → staging → production"
echo "3. Używaj odpowiednich inventory dla każdego środowiska"
echo "4. W produkcji używaj ograniczeń -l dla konkretnych hostów"
echo "5. Sprawdzaj wyniki po każdym kroku"
echo

echo -e "${GREEN}📚 DOKUMENTACJA:${NC}"
echo "- docs/INVENTORY-USAGE.md - szczegóły pracy z inventory"
echo "- docs/USER-MODULE.md - dokumentacja modułu user"
echo "- docs/SUDOERS-MODULE.md - dokumentacja modułu sudoers"
echo

echo -e "${GREEN}🚀 GOTOWE KOMENDY DO SKOPIOWANIA:${NC}"
echo
echo "# Test lokalny"
echo "./run-automation.sh -i inventory/localhost.yml user -e \"user=webmaster\" -c"
echo
echo "# Staging" 
echo "./run-automation.sh -i inventory/staging.yml user -e \"user=webmaster\" && \\"
echo "./run-automation.sh -i inventory/staging.yml sudoers -e \"user=webmaster commands_file=webmaster_commands\""
echo
echo "# Produkcja"
echo "./run-automation.sh -i inventory/production.yml user -e \"user=webmaster\" -c  # TEST!"
echo "./run-automation.sh -i inventory/production.yml user -e \"user=webmaster\" && \\"
echo "./run-automation.sh -i inventory/production.yml sudoers -e \"user=webmaster commands_file=webmaster_commands\""