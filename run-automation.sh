#!/bin/bash

# Skrypt uruchamiający automatyzację Linux Administrator
# Autor: Marek DevOps
# Data: 2025-10-10

set -euo pipefail

# Kolory dla outputu
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funkcja wyświetlania wiadomości
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}[$(date +'%Y-%m-%d %H:%M:%S')] ${message}${NC}"
}

print_info() { print_message "${BLUE}" "$1"; }
print_success() { print_message "${GREEN}" "$1"; }
print_warning() { print_message "${YELLOW}" "$1"; }
print_error() { print_message "${RED}" "$1"; }

# Domyślne wartości
INVENTORY_FILE="inventory/hosts.yml"
PLAYBOOK="site.yml"
TAGS=""
EXTRA_VARS=""
DRY_RUN=false
VERBOSE=false

# Funkcja pomocy
show_help() {
    cat << EOF
Ansible Linux Administrator Automation

UŻYCIE:
    $0 [OPCJE] [AKCJA]

OPCJE:
    -i, --inventory FILE     Plik inventory (domyślnie: inventory/hosts.yml)
    -t, --tags TAGS          Tagi do uruchomienia (np. system,security)
    -e, --extra-vars VARS    Dodatkowe zmienne (np. "update_system=true")
    -l, --limit HOSTS        Ograniczenie do określonych hostów
    -c, --check              Tryb dry-run (sprawdzenie bez zmian)
    -v, --verbose            Szczegółowy output
    -h, --help               Wyświetl tę pomoc

AKCJE:
    all                      Uruchom wszystkie zadania (domyślne)
    system                   Tylko zadania systemowe
    security                 Tylko zadania bezpieczeństwa
    services                 Tylko usługi
    monitoring               Tylko monitorowanie
    maintenance              Tylko konserwacja
    user                     Zarządzanie użytkownikami (pojedynczy)
    users                    Zarządzanie użytkownikami (wielu, z YAML)
    usersldap                Zarządzanie użytkownikami LDAP/AD (sss_override)
    sudoers                  Konfiguracja uprawnień sudo
    install                  Instalacja pakietów systemowych
    backup                   Zarządzanie archiwami i kopiami zapasowymi
    lvm                      Zarządzanie dyskami i wolumenami LVM
    raportinfra              Raport infrastruktury serwerów (CPU, RAM, Dyski, OS)
    check                    Sprawdzenie konfiguracji

PRZYKŁADY:
    # Podstawowe uruchomienie
    $0

    # Tylko aktualizacja systemu
    $0 -t update

    # Konfiguracja bezpieczeństwa z restartem
    $0 security -e "enable_firewall=true reboot_after_update=true"

    # Dry-run wszystkich zadań
    $0 -c

    # Ograniczenie do serwerów produkcyjnych
    $0 -l production

    # Szczegółowy output z tagami
    $0 -v -t system,security

    # Tworzenie użytkownika
    $0 user -e "user=jan home=default"
    
    # Użytkownik z niestandardowym katalogiem
    $0 user -e "user=tomcat home=/opt/tomcat"
    
    # Użytkownik z sudo
    $0 user -e "user=admin home=default sudo=true"
    
    # Zarządzanie wieloma użytkownikami
    $0 users -e "username=jan groups=docker,wheel"
    
    # Użytkownicy z katalogu domowego
    $0 users -e "username=tomcat home=/opt/tomcat groups=webadmin"
    
    # Wielu użytkowników z pliku YAML
    $0 users -e "@vars/users.yml"
    
    # Nadpisanie katalogu domowego użytkownika LDAP/AD
    $0 usersldap -e "username=jan.kowalski home=/home/jan"
    
    # Wielu użytkowników LDAP z pliku YAML
    $0 usersldap -e "@vars/usersldap.yml"
    
    # Konfiguracja sudoers
    $0 sudoers -e "user=webmaster"
    
    # Sudoers z niestandardowym plikiem komend
    $0 sudoers -e "user=admin commands_file=admin_commands"
    
    # Instalacja pakietów
    $0 install -e "package=vim"
    
    # Instalacja wielu pakietów
    $0 install -e "package=vim,git,curl,htop"
    
    # Instalacja z najnowszą wersją
    $0 install -e "package=nginx state=latest"
    
    # Kopia zapasowa (archive)
    $0 backup -e "task_action=archive source=/tomcat target=./backup"
    
    # Przywracanie (extract)
    $0 backup -e "task_action=extract source=./backup/tomcat_server1.tar.gz target=/tomcat"
    
    # Sprawdzenie dysków LVM
    $0 lvm -e "task_action=check"
    
    # Utworzenie wolumenu LVM
    $0 lvm -e "task_action=create disk=/dev/sdb size=20G name=/tomcat"
    
    # Rozszerzenie wolumenu LVM
    $0 lvm -e "task_action=extend lv_name=tomcat-lv vg_name=vg-data size=+10G"
    
    # Raport infrastruktury (format tekstowy)
    $0 raportinfra -i inventory/production.yml
    
    # Raport infrastruktury (format JSON)
    $0 raportinfra -i inventory/production.yml -e "format=json"
    
    # Raport infrastruktury (format CSV - dla wielu serwerów)
    $0 raportinfra -i inventory/production.yml -e "format=csv"
EOF
}

# Parsowanie argumentów
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--inventory)
            INVENTORY_FILE="$2"
            shift 2
            ;;
        -t|--tags)
            TAGS="$2"
            shift 2
            ;;
        -e|--extra-vars)
            EXTRA_VARS="$2"
            shift 2
            ;;
        -l|--limit)
            LIMIT="$2"
            shift 2
            ;;
        -c|--check)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        all)
            PLAYBOOK="site.yml"
            shift
            ;;
        system)
            PLAYBOOK="playbooks/system/main.yml"
            shift
            ;;
        security)
            PLAYBOOK="playbooks/security/main.yml"
            shift
            ;;
        services)
            PLAYBOOK="playbooks/services/main.yml"
            shift
            ;;
        monitoring)
            PLAYBOOK="playbooks/monitoring/main.yml"
            shift
            ;;
        maintenance)
            PLAYBOOK="playbooks/maintenance/main.yml"
            shift
            ;;
        user)
            PLAYBOOK="playbooks/user.yml"
            shift
            ;;
        users)
            PLAYBOOK="playbooks/users.yml"
            shift
            ;;
        usersldap)
            PLAYBOOK="playbooks/usersldap.yml"
            shift
            ;;
        sudoers)
            PLAYBOOK="playbooks/sudoers.yml"
            shift
            ;;
        install)
            PLAYBOOK="playbooks/install.yml"
            shift
            ;;
        backup)
            PLAYBOOK="playbooks/backup.yml"
            shift
            ;;
        lvm)
            PLAYBOOK="playbooks/lvm.yml"
            shift
            ;;
        raportinfra)
            PLAYBOOK="playbooks/raportinfra.yml"
            shift
            ;;
        check)
            PLAYBOOK="site.yml"
            TAGS="always"
            DRY_RUN=true
            shift
            ;;
        *)
            print_error "Nieznany argument: $1"
            show_help
            exit 1
            ;;
    esac
done

# Sprawdzenie wymagań
check_requirements() {
    print_info "Sprawdzanie wymagań..."
    
    # Sprawdź Ansible
    if ! command -v ansible-playbook &> /dev/null; then
        print_error "Ansible nie jest zainstalowany!"
        exit 1
    fi
    
    # Sprawdź wersję Ansible
    ansible_version=$(ansible --version | head -n1 | awk '{print $2}')
    print_success "Ansible version: $ansible_version"
    
    # Sprawdź plik inventory
    if [[ ! -f "$INVENTORY_FILE" ]]; then
        print_error "Plik inventory nie istnieje: $INVENTORY_FILE"
        exit 1
    fi
    
    # Sprawdź playbook
    if [[ ! -f "$PLAYBOOK" ]]; then
        print_error "Playbook nie istnieje: $PLAYBOOK"
        exit 1
    fi
    
    print_success "Wszystkie wymagania spełnione"
}

# Budowanie komendy ansible-playbook
build_ansible_command() {
    local cmd="ansible-playbook"
    
    # Inventory
    cmd="$cmd -i $INVENTORY_FILE"
    
    # Playbook
    cmd="$cmd $PLAYBOOK"
    
    # Tags
    if [[ -n "$TAGS" ]]; then
        cmd="$cmd --tags $TAGS"
    fi
    
    # Extra vars
    if [[ -n "$EXTRA_VARS" ]]; then
        cmd="$cmd --extra-vars \"$EXTRA_VARS\""
    fi
    
    # Limit
    if [[ -n "${LIMIT:-}" ]]; then
        cmd="$cmd --limit $LIMIT"
    fi
    
    # Dry run
    if [[ "$DRY_RUN" == true ]]; then
        cmd="$cmd --check --diff"
    fi
    
    # Verbose
    if [[ "$VERBOSE" == true ]]; then
        cmd="$cmd -vvv"
    fi
    
    echo "$cmd"
}

# Wyświetlanie podsumowania
show_summary() {
    print_info "=== PODSUMOWANIE KONFIGURACJI ==="
    echo "Inventory: $INVENTORY_FILE"
    echo "Playbook: $PLAYBOOK"
    echo "Tags: ${TAGS:-wszystkie}"
    echo "Extra vars: ${EXTRA_VARS:-brak}"
    echo "Limit: ${LIMIT:-wszystkie hosty}"
    echo "Dry run: $DRY_RUN"
    echo "Verbose: $VERBOSE"
    echo "=================================="
}

# Funkcja główna
main() {
    print_info "Uruchamianie Ansible Linux Administrator Automation"
    
    # Sprawdź wymagania
    check_requirements
    
    # Wyświetl podsumowanie
    show_summary
    
    # Zbuduj komendę
    ansible_cmd=$(build_ansible_command)
    
    print_info "Komenda do wykonania:"
    echo "$ansible_cmd"
    
    # Pytanie o kontynuację (jeśli nie dry-run)
    if [[ "$DRY_RUN" == false ]]; then
        print_warning "Czy chcesz kontynuować? [y/N]"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_info "Anulowano."
            exit 0
        fi
    fi
    
    # Wykonaj komendę
    print_info "Uruchamianie Ansible..."
    start_time=$(date +%s)
    
    if eval "$ansible_cmd"; then
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        print_success "Ansible zakończony pomyślnie! Czas wykonania: ${duration}s"
    else
        print_error "Ansible zakończony z błędem!"
        exit 1
    fi
}

# Uruchom funkcję główną
main