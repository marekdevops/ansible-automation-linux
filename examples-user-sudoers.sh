#!/bin/bash

# Przykład kombinacji modułów USER + SUDOERS
# Tworzy użytkownika i konfiguruje dla niego uprawnienia sudo

set -e

echo "=== EXAMPLE: USER + SUDOERS COMBINATION ==="
echo

# Kolory
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}KROK $1:${NC} $2"
}

print_info() {
    echo -e "${YELLOW}INFO:${NC} $1"
}

print_success() {
    echo -e "${GREEN}SUCCESS:${NC} $1"
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

# Przykład 1: WebMaster
echo "=== PRZYKŁAD 1: WEBMASTER ==="
echo
print_step "1" "Tworzy użytkownika 'webmaster'"
echo "./run-automation.sh user -e \"user=webmaster home=default\""
echo
print_step "2" "Konfiguruje uprawnienia sudo dla webmastera"
echo "./run-automation.sh sudoers -e \"user=webmaster commands_file=webmaster_commands\""
echo
print_info "Użytkownik webmaster będzie mógł bez hasła:"
print_info "- Restartować nginx/apache"
print_info "- Przeglądać logi"
print_info "- Zarządzać certyfikatami SSL"
echo

# Przykład 2: Docker Admin
echo "=== PRZYKŁAD 2: DOCKER ADMIN ==="
echo
print_step "1" "Tworzy użytkownika 'dockeradmin' z dostępem sudo"
echo "./run-automation.sh user -e \"user=dockeradmin home=default sudo=true\""
echo
print_step "2" "Konfiguruje dedykowane uprawnienia Docker"
echo "./run-automation.sh sudoers -e \"user=dockeradmin commands_file=docker_commands\""
echo
print_info "Użytkownik dockeradmin będzie mógł bez hasła:"
print_info "- Zarządzać kontenerami Docker"
print_info "- Używać docker-compose"
print_info "- Czyścić system Docker"
echo

# Przykład 3: Backup Operator
echo "=== PRZYKŁAD 3: BACKUP OPERATOR ==="
echo  
print_step "1" "Tworzy użytkownika 'backup' z katalogiem /backup"
echo "./run-automation.sh user -e \"user=backup home=/backup\""
echo
print_step "2" "Konfiguruje uprawnienia do operacji backup"
echo "./run-automation.sh sudoers -e \"user=backup commands_file=backup_commands\""
echo
print_info "Użytkownik backup będzie mógł bez hasła:"
print_info "- Montować/odmontowywać dyski"
print_info "- Tworzyć archiwa tar"
print_info "- Zarządzać bazami danych dla backupów"
echo

# Przykład 4: Kompletny workflow
echo "=== PRZYKŁAD 4: KOMPLETNY WORKFLOW ==="
echo
print_step "1" "Utwórz niestandardowe komendy (templates/myapp_commands)"
print_step "2" "Utwórz użytkownika: ./run-automation.sh user -e \"user=myapp home=/opt/myapp\""
print_step "3" "Konfiguruj sudo: ./run-automation.sh sudoers -e \"user=myapp commands_file=myapp_commands\""
print_step "4" "Sprawdź: sudo -l -U myapp"
echo

echo -e "${GREEN}=== GOTOWE KOMBINACJE DO SKOPIOWANIA ===${NC}"
echo
echo "# WebMaster (nginx + logi + certyfikaty)"
echo "./run-automation.sh user -e \"user=webmaster home=default\" && \\"
echo "./run-automation.sh sudoers -e \"user=webmaster commands_file=webmaster_commands\""
echo
echo "# Docker Admin (pełne uprawnienia Docker)"  
echo "./run-automation.sh user -e \"user=dockeradmin home=default sudo=true\" && \\"
echo "./run-automation.sh sudoers -e \"user=dockeradmin commands_file=docker_commands\""
echo
echo "# Backup Operator (backupy + bazy danych)"
echo "./run-automation.sh user -e \"user=backup home=/backup\" && \\"
echo "./run-automation.sh sudoers -e \"user=backup commands_file=backup_commands\""
echo

print_success "Moduły USER i SUDOERS działają razem!"
print_info "Dokumentacja: docs/USER-MODULE.md i docs/SUDOERS-MODULE.md"