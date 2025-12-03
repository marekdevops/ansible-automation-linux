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

## 💾 LVM MODULE - Zarządzanie dyskami i wolumenami

### Podstawowe użycie
```bash
# Sprawdź stan dysków i LVM
./run-automation.sh -i inventory/localhost.yml lvm -e "task_action=check"

# Utwórz nowy wolumin (50GB na /data)
./run-automation.sh -i inventory/production.yml lvm \
  -e "task_action=create disk=/dev/sdb size=50G name=/data"

# Rozszerz istniejący wolumin o 20GB
./run-automation.sh -i inventory/production.yml lvm \
  -e "task_action=extend lv_name=data-lv vg_name=vg-system size=+20G"
```

### Zaawansowane scenariusze
```bash
# Wiele wolumenów na jednym dysku (serwer WWW)
./run-automation.sh -i inventory/webservers.yml lvm \
  -e "task_action=create disk=/dev/sdc size=200G name=/var/www,/var/log,/opt"

# Serwer bazy danych (500GB dla PostgreSQL)
./run-automation.sh -i inventory/databases.yml lvm \
  -e "task_action=create disk=/dev/sdd size=500G name=/var/lib/postgresql"

# Serwer aplikacji z wieloma wolumenami
./run-automation.sh -i inventory/appservers.yml lvm \
  -e "task_action=create disk=/dev/sde size=300G name=/opt/tomcat,/data/uploads,/var/log/tomcat"
```

### Testowanie i bezpieczeństwo
```bash
# ZAWSZE testuj przed wykonaniem na produkcji (dry-run)
./run-automation.sh -i inventory/production.yml lvm \
  -e "task_action=create disk=/dev/sdb size=100G name=/data" -c

# Sprawdź wynik i jeśli OK, wykonaj bez -c
./run-automation.sh -i inventory/production.yml lvm \
  -e "task_action=create disk=/dev/sdb size=100G name=/data"

# Monitoruj po operacji
sudo vgs    # Volume Groups
sudo lvs    # Logical Volumes  
df -h       # Punkty montowania
```

### Integracja z backupami
```bash
# 1. Utwórz wolumin dla backupów
./run-automation.sh -i inventory/production.yml lvm \
  -e "task_action=create disk=/dev/sdf size=1T name=/backup"

# 2. Następnie konfiguruj backup (po utworzeniu LVM)
./run-automation.sh -i inventory/production.yml backup \
  -e "task_action=archive source=/var/www dest=/backup/www-$(date +%Y%m%d).tar.gz"
```

## 👥 USERS MODULE - Zaawansowane zarządzanie użytkownikami

### Podstawowe użycie (tryb pojedynczy)
```bash
# Utworzenie użytkownika z domyślnymi ustawieniami
./run-automation.sh users -e "username=jan"

# Użytkownik z grupami
./run-automation.sh users -e "username=jan groups=docker,wheel"

# Użytkownik z niestandardowym katalogiem
./run-automation.sh users -e "username=tomcat home=/opt/tomcat"

# Użytkownik z pełną konfiguracją
./run-automation.sh users -e "username=dbadmin home=/var/lib/dbadmin groups=dba,sudo shell=/bin/bash"

# Użytkownik systemowy
./run-automation.sh users -e "username=nginx system=true create_home=false shell=/usr/sbin/nologin"

# Usunięcie użytkownika
./run-automation.sh users -e "username=olduser state=absent"
```

### Tryb wsadowy (z pliku YAML)
```bash
# Utwórz plik vars/users.yml z listą użytkowników
cat > vars/users.yml << 'EOF'
---
users_list:
  - username: jan
    groups: docker,wheel
    comment: "Jan Kowalski - Developer"
  
  - username: anna
    groups: docker
    comment: "Anna Nowak - Frontend Developer"
  
  - username: tomcat
    home: /opt/tomcat
    groups: webadmin
    system: true
    comment: "Tomcat Application User"
EOF

# Wykonaj dla wszystkich użytkowników z pliku
./run-automation.sh users -e "@vars/users.yml"

# Testuj przed wykonaniem (dry-run)
./run-automation.sh users -e "@vars/users.yml" --check
```

### Zaawansowane scenariusze
```bash
# Dodaj deweloperów do zespołu
./run-automation.sh users -i inventory/development.yml -e "@vars/developers.yml"

# Skonfiguruj użytkowników aplikacji na produkcji
./run-automation.sh users -i inventory/production.yml -e "@vars/app_users.yml"

# Reorganizacja użytkownika (nowy katalog + grupy)
./run-automation.sh users -e "username=jan home=/home/users/jan groups=docker,k8s,developers"

# Czyszczenie starych użytkowników
cat > vars/cleanup.yml << 'EOF'
---
users_list:
  - username: olddev1
    state: absent
  - username: olddev2
    state: absent
EOF
./run-automation.sh users -e "@vars/cleanup.yml"
```

### Integracja z innymi modułami
```bash
# 1. Utwórz użytkownika aplikacji
./run-automation.sh users -e "username=tomcat home=/opt/tomcat groups=webadmin"

# 2. Skonfiguruj sudo dla użytkownika
./run-automation.sh sudoers -e "user=tomcat"

# 3. Utwórz LVM dla katalogu aplikacji
./run-automation.sh lvm -e "task_action=create disk=/dev/sdb size=100G name=/opt/tomcat"
```

## 📊 RAPORTINFRA MODULE - Raport infrastruktury serwerów

### Podstawowe użycie
```bash
# Raport pojedynczego serwera (format tekstowy)
./run-automation.sh raportinfra -i inventory/localhost.yml

# Raport wszystkich serwerów produkcyjnych
./run-automation.sh raportinfra -i inventory/production.yml

# Raport w formacie JSON
./run-automation.sh raportinfra -i inventory/production.yml -e "format=json"

# Raport w formacie CSV (dla wielu serwerów)
./run-automation.sh raportinfra -i inventory/production.yml -e "format=csv"
```

### Zaawansowane scenariusze
```bash
# Zapisz raport do pliku z datą
./run-automation.sh raportinfra -i inventory/production.yml > raport-$(date +%Y%m%d).txt

# Raport tylko serwerów baz danych
./run-automation.sh raportinfra -i inventory/production.yml -l databases

# Generuj CSV dla analizy w Excel
./run-automation.sh raportinfra -i inventory/hosts.yml -e "format=csv" > infra-report.csv

# Porównaj środowiska
./run-automation.sh raportinfra -i inventory/development.yml > dev.txt
./run-automation.sh raportinfra -i inventory/production.yml > prod.txt
diff dev.txt prod.txt
```

## 📊 Monitoring i troubleshooting

### Sprawdzanie stanu systemu po deployment
```bash
# Status wszystkich usług
ansible -i inventory/production.yml all -a "systemctl list-failed" -b

# Użycie dysków
ansible -i inventory/production.yml all -a "df -h" -b

# Status LVM (jeśli używany)
ansible -i inventory/production.yml all -a "sudo vgs && sudo lvs" -b

# Sprawdzenie logów systemowych
ansible -i inventory/production.yml all -a "journalctl --since '10 minutes ago' --no-pager" -b

# Raport infrastruktury wszystkich serwerów
./run-automation.sh raportinfra -i inventory/production.yml
```