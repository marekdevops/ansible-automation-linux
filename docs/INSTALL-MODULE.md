# Moduł INSTALL - Instalacja Pakietów Systemowych

## Opis
Moduł `install` umożliwia instalację pakietów systemowych na różnych dystrybucjach Linuxa za pomocą odpowiednich menedżerów pakietów.

## Obsługiwane systemy
- **Debian/Ubuntu**: apt
- **RHEL/CentOS/Fedora**: yum/dnf  
- **Arch Linux**: pacman
- **openSUSE**: zypper

## Użycie

### Podstawowe użycie
```bash
./run-automation.sh install -e "package=nazwa_pakietu"
```

### Parametry

| Parametr | Domyślna wartość | Opis |
|----------|------------------|------|
| `package` | - | Nazwa pakietu lub lista pakietów (wymagane) |
| `name` | - | Alias dla `package` (dla kompatybilności) |
| `state` | `present` | Stan pakietu: `present`, `latest`, `absent` |
| `update` | `true` | Czy aktualizować cache przed instalacją |
| `recommends` | `true` | Czy instalować rekomendowane pakiety (Debian/Ubuntu) |
| `force` | `false` | Czy wymuszać użycie apt-get zamiast apt (Debian/Ubuntu) |
| `cleanup` | `false` | Czy wyczyścić cache po instalacji |

## Przykłady użycia

### Instalacja pojedynczego pakietu
```bash
# Instalacja vim
./run-automation.sh install -e "package=vim"

# Instalacja z dry-run (sprawdzenie)
./run-automation.sh install -e "package=nginx" -c
```

### Instalacja wielu pakietów
```bash
# Lista pakietów oddzielona przecinkami
./run-automation.sh install -e "package=vim,git,curl,htop"

# Narzędzia programistyczne
./run-automation.sh install -e "package=python3,pip,nodejs,npm"
```

### Zaawansowane opcje
```bash
# Najnowsza wersja pakietu
./run-automation.sh install -e "package=nginx state=latest"

# Bez aktualizacji cache
./run-automation.sh install -e "package=docker.io update=false"

# Z czyszczeniem cache po instalacji
./run-automation.sh install -e "package=mysql-server cleanup=true"

# Bez pakietów rekomendowanych (Debian/Ubuntu)
./run-automation.sh install -e "package=apache2 recommends=false"
```

### Usuwanie pakietów
```bash
# Usunięcie pakietu
./run-automation.sh install -e "package=apache2 state=absent"
```

## Przykłady dla różnych środowisk

### Serwer webowy
```bash
./run-automation.sh install -e "package=nginx,php-fpm,mysql-server"
```

### Środowisko programistyczne
```bash
./run-automation.sh install -e "package=vim,git,curl,wget,htop,tree,jq"
```

### Narzędzia Docker
```bash
./run-automation.sh install -e "package=docker.io,docker-compose"
```

### Monitoring i diagnostyka
```bash
./run-automation.sh install -e "package=htop,iotop,nload,tcpdump,wireshark"
```

## Informacje zwrotne

Moduł wyświetla szczegółowe informacje o:
- Wykrytym systemie operacyjnym
- Statusie instalacji każdego pakietu
- Wersjach zainstalowanych pakietów
- Komendach do sprawdzenia instalacji

## Przykład output
```
=== INSTALACJA PAKIETÓW ===
Pakiety: vim, git, curl
Stan: present
Aktualizacja cache: True
System: Debian
Dystrybucja: Ubuntu 24.04

=== STATUS INSTALACJI ===
✅ vim: Zainstalowany (wersja: 2:9.1.0016-1ubuntu7.9)
✅ git: Zainstalowany (wersja: 1:2.43.0-1ubuntu7.3)  
✅ curl: Zainstalowany (wersja: 8.5.0-2ubuntu10.4)

=== POLECENIA SPRAWDZAJĄCE ===
Sprawdź vim: which vim || dpkg -l | grep vim
Sprawdź git: which git || dpkg -l | grep git
Sprawdź curl: which curl || dpkg -l | grep curl
```

## Integracja z inventory

### Dla różnych środowisk
```bash
# Produkcja
./run-automation.sh -i inventory/production.yml install -e "package=nginx,certbot"

# Staging  
./run-automation.sh -i inventory/staging.yml install -e "package=nginx"

# Localhost
./run-automation.sh -i inventory/localhost.yml install -e "package=vim,git"
```

## Obsługa błędów

Moduł automatycznie:
- Wykrywa system operacyjny
- Wybiera odpowiedni menedżer pakietów
- Sprawdza czy pakiety zostały zainstalowane
- Wyświetla błędy instalacji

## Bezpieczeństwo

- Wszystkie operacje wymagają uprawnień `sudo`
- Walidacja nazw pakietów przez menedżery pakietów
- Możliwość sprawdzenia zmian przez tryb dry-run (`-c`)

## Zobacz także

- [USER-MODULE.md](USER-MODULE.md) - Zarządzanie użytkownikami
- [SUDOERS-MODULE.md](SUDOERS-MODULE.md) - Konfiguracja uprawnień sudo
- [INVENTORY-USAGE.md](INVENTORY-USAGE.md) - Zarządzanie inventory