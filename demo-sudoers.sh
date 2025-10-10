#!/bin/bash

# Demo skrypt dla modułu SUDOERS
# Pokazuje różne sposoby konfiguracji uprawnień sudo

set -e

echo "=== DEMO MODUŁ SUDOERS ==="
echo

# Kolory
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

demo_cmd() {
    echo -e "${BLUE}Komenda: $1${NC}"
    echo "Opis: $2"
    echo "---"
    echo
}

echo "Oto przykłady użycia modułu SUDOERS:"
echo

demo_cmd "./run-automation.sh sudoers -e \"user=webmaster\"" \
         "Konfiguruje sudo dla webmastera (domyślne komendy)"

demo_cmd "./run-automation.sh sudoers -e \"user=dockeradmin commands_file=docker_commands\"" \
         "Konfiguruje sudo dla administratora Docker"

demo_cmd "./run-automation.sh sudoers -e \"user=backup commands_file=backup_commands\"" \
         "Konfiguruje sudo dla operatora backupów"

demo_cmd "./run-automation.sh sudoers -e \"user=webmaster commands_file=webmaster_commands\"" \
         "Konfiguruje sudo dla webmastera z dedykowanymi komendami"

demo_cmd "./run-automation.sh sudoers -e \"user=admin priority=99\"" \
         "Tworzy plik sudoers z priorytetem 99 (99-admin)"

echo -e "${YELLOW}=== DOSTĘPNE PLIKI Z KOMENDAMI ===${NC}"
echo "📁 templates/"
for file in /home/marek/CODE/ansible-automation-linux/templates/*_commands; do
    if [[ -f "$file" ]]; then
        basename "$file"
    fi
done
echo "📁 sudo_commands (domyślny)"
echo

echo -e "${GREEN}Aby uruchomić przykład:${NC}"
echo "1. Skopiuj komendę"
echo "2. Dostosuj nazwę użytkownika"
echo "3. Upewnij się że użytkownik istnieje (użyj modułu 'user' jeśli nie)"
echo "4. Uruchom komendę"
echo
echo -e "${GREEN}Sprawdzanie uprawnień:${NC}"
echo "sudo -l -U UŻYTKOWNIK  # Sprawdź uprawnienia"
echo "ls -la /etc/sudoers.d/ # Pokaż pliki sudoers"
echo
echo "Więcej informacji: docs/SUDOERS-MODULE.md"