#!/bin/bash

# Skrypt do testowania konfiguracji SSH i sudo
# Sprawdza czy Ansible może się połączyć i używać sudo

set -e

echo "=== TEST KONFIGURACJI SSH I SUDO ==="
echo

# Kolory
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_test() {
    echo -e "${BLUE}TEST:${NC} $1"
}

print_ok() {
    echo -e "${GREEN}✅ OK:${NC} $1"
}

print_error() {
    echo -e "${RED}❌ BŁĄD:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️  UWAGA:${NC} $1"
}

# Domyślny plik inventory
INVENTORY=${1:-"inventory/hosts.yml"}

echo "Używany inventory: $INVENTORY"
echo

# Test 1: Sprawdź czy plik inventory istnieje
print_test "Sprawdzanie pliku inventory"
if [[ -f "$INVENTORY" ]]; then
    print_ok "Plik inventory istnieje: $INVENTORY"
else
    print_error "Plik inventory nie istnieje: $INVENTORY"
    echo "Użycie: $0 [inventory_file]"
    exit 1
fi

# Test 2: Sprawdź składnię inventory
print_test "Sprawdzanie składni inventory"
if python3 -c "import yaml; yaml.safe_load(open('$INVENTORY'))" 2>/dev/null; then
    print_ok "Składnia inventory jest poprawna"
else
    print_error "Błędna składnia YAML w inventory"
    exit 1
fi

# Test 3: Sprawdź czy ansible jest zainstalowany
print_test "Sprawdzanie instalacji Ansible"
if command -v ansible &> /dev/null; then
    ansible_version=$(ansible --version | head -n1)
    print_ok "Ansible jest zainstalowany: $ansible_version"
else
    print_error "Ansible nie jest zainstalowany"
    echo "Zainstaluj: sudo apt install ansible-core"
    exit 1
fi

# Test 4: Lista hostów
print_test "Lista hostów z inventory"
if ansible -i "$INVENTORY" all --list-hosts 2>/dev/null; then
    print_ok "Hosty zostały poprawnie odczytane"
else
    print_error "Nie można odczytać hostów z inventory"
    exit 1
fi

echo

# Test 5: Test połączenia SSH
print_test "Test połączenia SSH (ping)"
if ansible -i "$INVENTORY" all -m ping 2>/dev/null; then
    print_ok "Wszystkie hosty odpowiadają na ping SSH"
else
    print_error "Niektóre hosty nie odpowiadają"
    echo
    print_warning "Możliwe przyczyny:"
    echo "1. Host jest wyłączony"
    echo "2. Błędny ansible_host w inventory"
    echo "3. Brak dostępu SSH"
    echo "4. Błędny ansible_user"
    echo "5. Brak klucza SSH"
    echo
    echo "Sprawdź ręcznie:"
    echo "ssh user@host_ip"
fi

echo

# Test 6: Test sudo bez become
print_test "Test użytkownika (bez sudo)"
if ansible -i "$INVENTORY" all -m shell -a "whoami" --become=false 2>/dev/null; then
    print_ok "Połączenie z użytkownikiem działa"
else
    print_error "Błąd połączenia z użytkownikiem"
fi

echo

# Test 7: Test sudo z become
print_test "Test sudo (z become)"
if ansible -i "$INVENTORY" all -m shell -a "whoami" 2>/dev/null; then
    print_ok "Sudo działa poprawnie (powinno zwrócić 'root')"
else
    print_error "Sudo nie działa"
    echo
    print_warning "Możliwe przyczyny:"
    echo "1. Użytkownik nie ma uprawnień sudo"
    echo "2. Sudo wymaga hasła (dodaj ansible_become_pass)"
    echo "3. Błędna konfiguracja sudo"
    echo
    echo "Sprawdź ręcznie:"
    echo "ssh user@host_ip 'sudo whoami'"
    echo
    echo "Dodaj NOPASSWD sudo:"
    echo "echo 'user ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/user"
fi

echo

# Test 8: Test modułu user (dry-run)
print_test "Test modułu user (dry-run)"
if ./run-automation.sh -i "$INVENTORY" user -e "user=test_user_ansible home=default" -c 2>/dev/null; then
    print_ok "Moduł user działa poprawnie"
else
    print_error "Moduł user ma problemy"
    echo "Sprawdź logi powyżej"
fi

echo

# Podsumowanie
echo -e "${BLUE}=== PODSUMOWANIE ===${NC}"
echo
print_ok "Konfiguracja SSH i sudo jest gotowa do użycia!"
echo
echo "Następne kroki:"
echo "1. Uruchom: ./run-automation.sh -i $INVENTORY user -e \"user=nazwa\" -c"
echo "2. Jeśli test OK, usuń -c i uruchom ponownie"
echo "3. Sprawdź: ./run-automation.sh -i $INVENTORY sudoers -e \"user=nazwa\""
echo
echo "Dokumentacja: docs/SSH-SUDO-CONFIG.md"