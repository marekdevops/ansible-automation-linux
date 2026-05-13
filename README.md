# Ansible Linux Administrator Automation

Kompleksowa rola Ansible do automatyzacji zadań administratora systemu Linux.

## 📋 Spis treści

- [Struktura projektu](#struktura-projektu)
- [Wymagania](#wymagania)
- [Instalacja](#instalacja)
- [Konfiguracja](#konfiguracja)
- [Użycie](#użycie)
- [Moduły](#moduły)
- [Zmienne](#zmienne)
- [Przykłady](#przykłady)

## 🏗️ Struktura projektu

```
ansible-automation-linux/
├── README.md                    # Dokumentacja główna
├── site.yml                     # Główny playbook
├── inventory/                   # Pliki inventory
│   ├── hosts.yml               # Główny plik inventory
│   └── group_vars/             # Zmienne dla grup hostów
├── playbooks/                  # Playbooki modułowe
│   ├── system/                 # Zadania systemowe
│   ├── security/               # Bezpieczeństwo
│   ├── monitoring/             # Monitorowanie
│   ├── services/               # Usługi
│   └── maintenance/            # Konserwacja
├── roles/                      # Role Ansible
│   └── linux_admin/            # Główna rola
├── vars/                       # Pliki zmiennych
├── templates/                  # Szablony plików
├── files/                      # Pliki statyczne
└── ansible.cfg                 # Konfiguracja Ansible
```

## ⚙️ Wymagania

- Ansible >= 2.12
- Python >= 3.8
- SSH access do hostów docelowych
- Sudo privileges na hostach docelowych

## 🚀 Instalacja

1. Sklonuj repozytorium:
```bash
git clone <repository-url>
cd ansible-automation-linux
```

2. Zainstaluj wymagane kolekcje Ansible:
```bash
ansible-galaxy collection install -r requirements.yml
```

## 🔧 Konfiguracja

### 1. Wybierz odpowiedni plik inventory

Dostępne środowiska:
- `inventory/hosts.yml` - główny plik (domyślny)
- `inventory/production.yml` - środowisko produkcyjne 
- `inventory/staging.yml` - środowisko testowe
- `inventory/development.yml` - środowisko deweloperskie
- `inventory/localhost.yml` - testy lokalne

### 2. Skonfiguruj inventory

Edytuj odpowiedni plik inventory, np. `inventory/production.yml`:
```yaml
all:
  children:
    production:
      hosts:
        server1:
          ansible_host: 192.168.1.10
        server2:
          ansible_host: 192.168.1.11
    staging:
      hosts:
        test-server:
          ansible_host: 192.168.1.20
```

### 2. Ustaw zmienne globalne

Dostosuj zmienne w `vars/main.yml` lub użyj extra-vars.

## 🎯 Użycie

### Podstawowe uruchomienie

```bash
# Domyślny inventory (inventory/hosts.yml)
./run-automation.sh

# Określony plik inventory
./run-automation.sh -i inventory/production.yml
./run-automation.sh -i inventory/staging.yml
./run-automation.sh -i inventory/development.yml

# Z extra-vars i konkretnym inventory
./run-automation.sh -i inventory/production.yml \
  -e "enable_firewall=true update_system=true"
```

### Uruchomienie z tagami

```bash
# Tylko aktualizacje systemu
ansible-playbook -i inventory/hosts.yml site.yml --tags "update"

# Tylko bezpieczeństwo
ansible-playbook -i inventory/hosts.yml site.yml --tags "security"

# Tylko monitorowanie
ansible-playbook -i inventory/hosts.yml site.yml --tags "monitoring"
```

## 📦 Moduły

| Moduł | Opis | Status |
|-------|------|--------|
| **System** | | |
| - system-update | Aktualizacja systemu i pakietów | ✅ Planned |
| - user-management | Zarządzanie użytkownikami | ✅ Planned |
| **User** | | |
| - user | Tworzenie i zarządzanie pojedynczym użytkownikiem | ✅ Ready |
| - users | Zaawansowane zarządzanie wieloma użytkownikami | ✅ Ready |
| - usersldap | Zarządzanie użytkownikami LDAP/AD (sss_override) | ✅ Ready |
| - sudoers | Konfiguracja uprawnień sudo | ✅ Ready |
| **Disk** | | |
| - lvm | Zarządzanie dyskami i wolumenami LVM | ✅ Ready |
| - backup | Archiwizacja i przywracanie danych | ✅ Ready |
| **System** | | |
| - install | Instalacja pakietów systemowych | ✅ Ready |
| - raportinfra | Raport infrastruktury serwerów | ✅ Ready |
| **Security** | | |
| - firewall | Konfiguracja firewall | ✅ Planned |
| - ssh-hardening | Wzmocnienie SSH | ✅ Planned |
| - fail2ban | Konfiguracja Fail2ban | ✅ Planned |
| **Services** | | |
| - web-server | Nginx/Apache | ✅ Planned |
| - database | MySQL/PostgreSQL | ✅ Planned |
| - docker | Docker & Docker Compose | ✅ Planned |
| **Monitoring** | | |
| - system-monitoring | Monitoring systemu | ✅ Planned |
| - log-management | Zarządzanie logami | ✅ Planned |
| **Maintenance** | | |
| - backup | System backupów | ✅ Planned |
| - cleanup | Czyszczenie systemu | ✅ Planned |

## 🔧 Zmienne

### Zmienne globalne (extra-vars)

```yaml
# System
update_system: true
reboot_after_update: false
install_additional_packages: []

# Security
enable_firewall: true
ssh_port: 22
disable_root_login: true

# Services
install_docker: false
install_nginx: false

# Monitoring
install_monitoring: false
monitoring_type: "prometheus"

# Backup
enable_backup: false
backup_destination: "/backup"
```

### Zmienne inventory

Możesz ustawić zmienne specyficzne dla hostów w `inventory/group_vars/`:

```yaml
# inventory/group_vars/production.yml
ansible_user: admin
ansible_become: true
ssh_port: 2222
```

## 📝 Przykłady użycia

### 1. Podstawowa konfiguracja serwera

```bash
ansible-playbook -i inventory/hosts.yml site.yml \
  --extra-vars "update_system=true enable_firewall=true ssh_port=2222"
```

### 2. Instalacja web serwera

```bash
ansible-playbook -i inventory/hosts.yml playbooks/services/web-server.yml \
  --extra-vars "web_server=nginx domain=example.com"
```

### 3. Tworzenie użytkowników

```bash
# Podstawowy użytkownik
./run-automation.sh user -e "user=jan home=default"

# Użytkownik z niestandardowym katalogiem
./run-automation.sh user -e "user=tomcat home=/opt/tomcat"

# Administrator z sudo
./run-automation.sh user -e "user=admin home=default sudo=true"
```

### 4. Konfiguracja uprawnień sudo

```bash
# Podstawowe uprawnienia sudo
./run-automation.sh sudoers -e "user=webmaster"

# Dedykowane komendy Docker
./run-automation.sh sudoers -e "user=dockeradmin commands_file=docker_commands"

# Operatore backupów
./run-automation.sh sudoers -e "user=backup commands_file=backup_commands"

# Tymczasowe pełne uprawnienia root NOPASSWD (np. na czas incydentu)
./run-automation.sh sudoers -e "task_action=grant user=jasiu"

# Odebranie tych uprawnień
./run-automation.sh sudoers -e "task_action=revoke user=jasiu"
```

### 5. Konfiguracja monitoringu

```bash
ansible-playbook -i inventory/hosts.yml playbooks/monitoring/system-monitoring.yml \
  --extra-vars "monitoring_type=prometheus grafana_enabled=true"
```

## 📚 Dokumentacja modułów

- 👤 [USER MODULE](docs/USER-MODULE.md) - Zarządzanie użytkownikami
- 🔐 [SUDOERS MODULE](docs/SUDOERS-MODULE.md) - Konfiguracja sudo
- 📦 [INSTALL MODULE](docs/INSTALL-MODULE.md) - Instalacja pakietów  
- 🗄️ [BACKUP MODULE](docs/BACKUP-MODULE.md) - Backup i archiwa
- 💾 [LVM MODULE](docs/LVM-MODULE.md) - Zarządzanie dyskami LVM
- 📊 [RAPORTINFRA MODULE](docs/RAPORTINFRA-MODULE.md) - Raport infrastruktury serwerów
- 🔧 [INVENTORY USAGE](docs/INVENTORY-USAGE.md) - Konfiguracja inventory
- 🔑 [SSH SUDO CONFIG](docs/SSH-SUDO-CONFIG.md) - Konfiguracja SSH i sudo

## 🤝 Rozwój

Aby dodać nowy moduł:

1. Utwórz nowy playbook w odpowiednim katalogu
2. Dodaj odpowiednie zmienne do `vars/`
3. Zaktualizuj `site.yml`
4. Dodaj dokumentację do README.md
5. Uaktualnij `run-automation.sh` o nowy moduł

## 📄 Licencja

MIT License

## 👥 Autorzy

- Marek DevOps

---

**Uwaga:** Ten projekt jest w fazie rozwoju. Moduły będą dodawane stopniowo.