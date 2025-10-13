# Praca z różnymi plikami Inventory

## Dostępne pliki inventory

```
inventory/
├── hosts.yml          # Główny plik (domyślny)
├── production.yml      # Środowisko produkcyjne
├── staging.yml         # Środowisko testowe
├── development.yml     # Środowisko deweloperskie
├── localhost.yml       # Tylko localhost
└── test-local.yml      # Test lokalny (prosty)
```

## Podstawowe użycie

### 1. Domyślny inventory (hosts.yml)
```bash
# Używa inventory/hosts.yml (domyślnie)
./run-automation.sh user -e "user=jan"
```

### 2. Określenie konkretnego pliku inventory
```bash
# Użyj opcji -i lub --inventory
./run-automation.sh -i inventory/production.yml user -e "user=jan"
./run-automation.sh --inventory inventory/staging.yml user -e "user=jan"
```

## Przykłady dla różnych środowisk

### PRODUKCJA
```bash
# Tworzenie użytkowników w produkcji
./run-automation.sh -i inventory/production.yml user -e "user=webmaster home=default"
./run-automation.sh -i inventory/production.yml sudoers -e "user=webmaster commands_file=webmaster_commands"

# Bezpieczeństwo w produkcji (automatycznie używa restrykcyjnych ustawień)
./run-automation.sh -i inventory/production.yml security

# Aktualizacja bez restartu (produkcja)
./run-automation.sh -i inventory/production.yml -t update
```

### STAGING
```bash
# Testowanie w staging (mniej restrykcyjne)
./run-automation.sh -i inventory/staging.yml user -e "user=tester home=default"
./run-automation.sh -i inventory/staging.yml sudoers -e "user=tester"

# Aktualizacja z restartem (staging pozwala)
./run-automation.sh -i inventory/staging.yml -t update
```

### DEVELOPMENT
```bash
# Środowisko deweloperskie (maksymalna swoboda)
./run-automation.sh -i inventory/development.yml user -e "user=developer home=default sudo=true"
./run-automation.sh -i inventory/development.yml -e "install_dev_tools=true install_docker=true"
```

### LOCALHOST (testing)
```bash
# Tylko na localhost (bezpieczne testowanie)
./run-automation.sh -i inventory/localhost.yml user -e "user=testuser home=default" -c
./run-automation.sh -i inventory/localhost.yml sudoers -e "user=testuser" -c
```

## Zaawansowane przykłady

### 1. Ograniczenie do konkretnych hostów
```bash
# Tylko webservery w produkcji
./run-automation.sh -i inventory/production.yml -l webservers user -e "user=webadmin"

# Tylko konkretny host
./run-automation.sh -i inventory/production.yml -l prod-web01 sudoers -e "user=webadmin"
```

### 2. Różne konfiguracje per środowisko
```bash
# Produkcja - bezpieczne ustawienia (automatyczne z inventory)
./run-automation.sh -i inventory/production.yml security

# Staging - podstawowe zabezpieczenia
./run-automation.sh -i inventory/staging.yml security -e "enable_firewall=true"

# Development - minimalne zabezpieczenia  
./run-automation.sh -i inventory/development.yml security -e "enable_firewall=false ssh_port=22"
```

### 3. Kombinacje user + sudoers per środowisko
```bash
# PRODUKCJA: Webmaster z pełnym zabezpieczeniem
./run-automation.sh -i inventory/production.yml user -e "user=webmaster home=default" && \
./run-automation.sh -i inventory/production.yml sudoers -e "user=webmaster commands_file=webmaster_commands"

# STAGING: Tester z podstawowymi uprawnieniami  
./run-automation.sh -i inventory/staging.yml user -e "user=tester home=default sudo=true" && \
./run-automation.sh -i inventory/staging.yml sudoers -e "user=tester"

# DEVELOPMENT: Developer z pełnymi uprawnieniami
./run-automation.sh -i inventory/development.yml user -e "user=developer home=default sudo=true" && \
./run-automation.sh -i inventory/development.yml sudoers -e "user=developer commands_file=docker_commands"
```

## Sprawdzenie konfiguracji inventory

### 1. Lista hostów
```bash
# Pokaż wszystkie hosty z inventory
ansible -i inventory/production.yml all --list-hosts
ansible -i inventory/staging.yml all --list-hosts
```

### 2. Sprawdź zmienne
```bash
# Sprawdź zmienne dla hostów
ansible -i inventory/production.yml all -m debug -a "var=hostvars[inventory_hostname]"
```

### 3. Test połączenia
```bash  
# Sprawdź połączenie z hostami
ansible -i inventory/production.yml all -m ping
ansible -i inventory/staging.yml webservers -m ping
```

## Tworzenie własnego inventory

### 1. Utwórz plik inventory/myproject.yml
```yaml
---
myproject:
  hosts:
    server1:
      ansible_host: IP_ADDRESS
      ansible_user: USERNAME
    server2:
      ansible_host: IP_ADDRESS  
      ansible_user: USERNAME
  
  vars:
    environment: custom
    ssh_port: 22
    enable_firewall: true
    # Twoje zmienne...
```

### 2. Użyj swojego inventory
```bash
./run-automation.sh -i inventory/myproject.yml user -e "user=myuser"
```

## Dry-run dla różnych środowisk

```bash
# Sprawdź co zostanie zrobione w każdym środowisku
./run-automation.sh -i inventory/production.yml user -e "user=admin" -c
./run-automation.sh -i inventory/staging.yml user -e "user=admin" -c  
./run-automation.sh -i inventory/development.yml user -e "user=admin" -c
```

## Najlepsze praktyki

### 1. Nazewnictwo plików
- `production.yml` - środowisko produkcyjne
- `staging.yml` - środowisko testowe  
- `development.yml` - środowisko deweloperskie
- `localhost.yml` - testy lokalne

### 2. Zmienne per środowisko
- Używaj `group_vars/` dla zmiennych wspólnych
- Definiuj environment-specific zmienne w inventory
- Produkcja = maksymalne bezpieczeństwo
- Development = maksymalna wygoda

### 3. Testowanie
- Zawsze używaj `-c` (dry-run) przed rzeczywistym uruchomieniem
- Testuj na staging przed produkcją
- Używaj localhost.yml dla lokalnych testów

## Przykładowy workflow

```bash
# 1. Test lokalny
./run-automation.sh -i inventory/localhost.yml user -e "user=test" -c

# 2. Test na staging
./run-automation.sh -i inventory/staging.yml user -e "user=webmaster" -c
./run-automation.sh -i inventory/staging.yml user -e "user=webmaster"

# 3. Wdrożenie na produkcję
./run-automation.sh -i inventory/production.yml user -e "user=webmaster" -c
./run-automation.sh -i inventory/production.yml user -e "user=webmaster"
```