# Przykłady użycia Ansible Linux Administrator Automation

## Podstawowe przykłady

### 1. Uruchomienie wszystkich zadań
```bash
# Podstawowe uruchomienie na wszystkich hostach
./run-automation.sh

# Z wykorzystaniem ansible-playbook bezpośrednio
ansible-playbook -i inventory/hosts.yml site.yml
```

### 2. Aktualizacja systemu
```bash
# Tylko aktualizacja pakietów
./run-automation.sh -t update

# Aktualizacja z restartem
./run-automation.sh -t update -e "reboot_after_update=true"

# Dry-run aktualizacji
./run-automation.sh -t update -c
```

### 3. Konfiguracja bezpieczeństwa
```bash
# Podstawowe wzmocnienie bezpieczeństwa
./run-automation.sh security

# Konfiguracja SSH z niestandardowym portem
./run-automation.sh security -e "ssh_port=2222"

# Włączenie firewall i fail2ban
./run-automation.sh security -e "enable_firewall=true install_fail2ban=true"
```

### 4. Instalacja usług
```bash
# Instalacja Nginx
./run-automation.sh services -e "install_nginx=true"

# Instalacja Docker
./run-automation.sh services -e "install_docker=true"

# Instalacja bazy MySQL
./run-automation.sh services -e "install_mysql=true mysql_root_password=SecurePass123!"
```

### 5. Praca z tagami
```bash
# Tylko zadania związane z użytkownikami
./run-automation.sh -t users

# Konfiguracja czasu i NTP
./run-automation.sh -t time,ntp

# Wszystkie zadania systemowe
./run-automation.sh -t system
```

### 6. Ograniczenie do konkretnych hostów
```bash
# Tylko serwery produkcyjne
./run-automation.sh -l production

# Konkretny host
./run-automation.sh -l server1

# Grupa serwerów web
./run-automation.sh -l webservers
```

## Zaawansowane przykłady

### 1. Kompleksowa konfiguracja serwera web
```bash
ansible-playbook -i inventory/hosts.yml site.yml \
  --limit webservers \
  --extra-vars "
    install_nginx=true
    enable_firewall=true
    install_fail2ban=true
    ssl_enabled=true
    domain=example.com
  "
```

### 2. Konfiguracja serwera bazy danych
```bash
ansible-playbook -i inventory/hosts.yml playbooks/services/database.yml \
  --extra-vars "
    install_mysql=true
    mysql_root_password=VerySecurePassword123!
    mysql_max_connections=500
    backup_enabled=true
    monitoring_enabled=true
  "
```

### 3. Setup środowiska deweloperskiego
```bash
ansible-playbook -i inventory/hosts.yml site.yml \
  --limit development \
  --extra-vars "
    install_dev_tools=true
    install_docker=true
    disable_root_login=false
    enable_firewall=false
    ssh_port=22
  "
```

### 4. Konserwacja i backup
```bash
# Konfiguracja systemu backup
ansible-playbook -i inventory/hosts.yml playbooks/maintenance/main.yml \
  --extra-vars "
    enable_backup=true
    backup_time='03:00'
    backup_retention_days=14
    cleanup_enabled=true
  "

# Jednorazowe czyszczenie systemu
ansible-playbook -i inventory/hosts.yml playbooks/maintenance/cleanup.yml
```

### 5. Monitoring i logi
```bash
ansible-playbook -i inventory/hosts.yml playbooks/monitoring/main.yml \
  --extra-vars "
    install_prometheus=true
    install_grafana=true
    configure_logging=true
    log_retention_days=30
  "
```

## Zmienne środowiskowe

### Extra-vars do przekazywania
```yaml
# Podstawowe
update_system: true
reboot_after_update: false
timezone: "Europe/Warsaw"

# Bezpieczeństwo
enable_firewall: true
ssh_port: 2222
disable_root_login: true
install_fail2ban: true

# Usługi
install_nginx: true
install_docker: true
install_mysql: false

# Monitoring
install_monitoring: true
monitoring_type: "prometheus"

# Backup
enable_backup: true
backup_destination: "/backup"
backup_time: "02:00"
```

### Konfiguracja w inventory
```yaml
# inventory/group_vars/production.yml
ansible_user: admin
ansible_become: true
ssh_port: 2222
enable_firewall: true
backup_enabled: true
monitoring_enabled: true

# inventory/group_vars/development.yml  
ansible_user: vagrant
ssh_port: 22
enable_firewall: false
backup_enabled: false
install_dev_tools: true
```

## Debugowanie

### 1. Sprawdzenie konfiguracji
```bash
# Test połączenia
ansible -i inventory/hosts.yml all -m ping

# Sprawdzenie zmiennych
ansible -i inventory/hosts.yml all -m setup

# Dry-run z detalami
./run-automation.sh -c -v
```

### 2. Uruchamianie krok po kroku
```bash
# Tylko sprawdzenie wymagań
ansible-playbook -i inventory/hosts.yml site.yml --tags always

# Tylko zadania systemowe
ansible-playbook -i inventory/hosts.yml site.yml --tags system --step
```

### 3. Logowanie
```bash
# Z pełnym logowaniem
ANSIBLE_LOG_PATH=./ansible.log ./run-automation.sh -v

# Sprawdzenie logów
tail -f ansible.log
```

## Integracja z CI/CD

### GitLab CI przykład
```yaml
# .gitlab-ci.yml
stages:
  - test
  - deploy

ansible-test:
  stage: test
  script:
    - ansible-playbook -i inventory/staging.yml site.yml --check

ansible-deploy:
  stage: deploy
  script:
    - ./run-automation.sh -l production
  only:
    - main
```

### Jenkins przykład
```groovy
pipeline {
    agent any
    stages {
        stage('Ansible Deploy') {
            steps {
                sh './run-automation.sh -l ${ENVIRONMENT}'
            }
        }
    }
}
```