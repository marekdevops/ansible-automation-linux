# LVM MODULE - Zarządzanie dyskami i wolumenami LVM

## Opis
Moduł LVM umożliwia zarządzanie dyskami i wolumenami logicznymi (LVM) na systemach Linux. 
Wspiera tworzenie nowych wolumenów, rozszerzanie istniejących oraz monitorowanie stanu dysków.

## Funkcjonalności

### 1. CHECK - Sprawdzenie stanu LVM
- Wyświetla dostępne dyski blokowe
- Pokazuje nieużywane dyski
- Listuje istniejące Volume Groups
- Wyświetla Logical Volumes
- Pokazuje zamontowane systemy plików

### 2. CREATE - Tworzenie nowych wolumenów
- Automatyczne tworzenie partycji LVM
- Konfiguracja Physical Volumes
- Tworzenie Volume Groups i Logical Volumes
- Formatowanie z systemem plików XFS
- Automatyczne montowanie i konfiguracja fstab

### 3. EXTEND - Rozszerzanie wolumenów
- Rozszerzanie istniejących Logical Volumes
- Automatyczne rozszerzanie systemów plików XFS
- Bezpieczna walidacja przed operacjami

## Wymagania

### Pakiety systemu
```bash
# Ubuntu/Debian
sudo apt-get install lvm2

# CentOS/RHEL/Rocky
sudo yum install lvm2

# Fedora
sudo dnf install lvm2
```

### Uprawnienia
- Wykonanie z uprawnieniami sudo
- Dostęp do urządzeń blokowych (/dev/*)

## Użycie

### Podstawowa składnia
```bash
./run-automation.sh -i <inventory> lvm -e "task_action=<akcja> [parametry]"
```

### Sprawdzenie stanu LVM
```bash
# Sprawdź stan dysków i wolumenów
./run-automation.sh -i inventory/localhost.yml lvm -e "task_action=check"

# Tryb dry-run (bezpieczny)
./run-automation.sh -i inventory/localhost.yml lvm -e "task_action=check" -c
```

### Tworzenie nowych wolumenów

#### Pojedynczy wolumin
```bash
# Utwórz wolumin 50GB na dysku /dev/sdb z punktem montowania /data
./run-automation.sh -i inventory/production.yml lvm \
  -e "task_action=create disk=/dev/sdb size=50G name=/data"

# Wiele wolumenów na jednym dysku
./run-automation.sh -i inventory/production.yml lvm \
  -e "task_action=create disk=/dev/sdc size=100G name=/var/log,/var/www,/opt"
```

#### Zaawansowane opcje
```bash
# Określenie liczby partycji i systemu plików
./run-automation.sh -i inventory/production.yml lvm \
  -e "task_action=create disk=/dev/sdd size=200G name=/tomcat partitions=1 filesystem=xfs"

# Tryb testowy (dry-run)
./run-automation.sh -i inventory/production.yml lvm \
  -e "task_action=create disk=/dev/sde size=100G name=/data" -c
```

### Rozszerzanie wolumenów
```bash
# Rozszerz istniejący Logical Volume o 20GB
./run-automation.sh -i inventory/production.yml lvm \
  -e "task_action=extend lv_name=tomcat-lv vg_name=vg-data size=+20G"

# Ustaw konkretny rozmiar (np. 100GB)
./run-automation.sh -i inventory/production.yml lvm \
  -e "task_action=extend lv_name=data-lv vg_name=vg-system size=100G"

# Tryb testowy
./run-automation.sh -i inventory/production.yml lvm \
  -e "task_action=extend lv_name=www-lv vg_name=vg-web size=+50G" -c
```

## Parametry

### Wspólne parametry
| Parametr | Opis | Wymagany | Przykład |
|----------|------|----------|----------|
| `task_action` | Akcja do wykonania (check/create/extend) | Tak | `create` |

### Parametry dla CREATE
| Parametr | Opis | Wymagany | Domyślny | Przykład |
|----------|------|----------|----------|----------|
| `disk` | Ścieżka do dysku | Tak | - | `/dev/sdb` |
| `size` | Rozmiar wolumenu | Tak | - | `100G` |
| `name` | Punkt(y) montowania | Tak | - | `/data` lub `/var/log,/opt` |
| `partitions` | Liczba partycji | Nie | 1 | `1` |
| `filesystem` | System plików | Nie | `xfs` | `xfs` |

### Parametry dla EXTEND
| Parametr | Opis | Wymagany | Przykład |
|----------|------|----------|----------|
| `lv_name` | Nazwa Logical Volume | Tak | `tomcat-lv` |
| `vg_name` | Nazwa Volume Group | Tak | `vg-data` |
| `size` | Rozmiar rozszerzenia | Tak | `+20G` lub `100G` |

## Przykłady zastosowania

### Scenariusz 1: Serwer WWW
```bash
# 1. Sprawdź dostępne dyski
./run-automation.sh -i inventory/webservers.yml lvm -e "task_action=check"

# 2. Utwórz dysk dla Apache/Nginx
./run-automation.sh -i inventory/webservers.yml lvm \
  -e "task_action=create disk=/dev/sdb size=100G name=/var/www"

# 3. Po czasie rozszerz wolumin
./run-automation.sh -i inventory/webservers.yml lvm \
  -e "task_action=extend lv_name=var-www-lv vg_name=vg-data size=+50G"
```

### Scenariusz 2: Serwer aplikacji
```bash
# Utwórz wiele wolumenów na jednym dysku
./run-automation.sh -i inventory/appservers.yml lvm \
  -e "task_action=create disk=/dev/sdc size=200G name=/opt/tomcat,/var/log/tomcat,/data/uploads"
```

### Scenariusz 3: Serwer bazy danych
```bash
# Dysk dedykowany dla PostgreSQL
./run-automation.sh -i inventory/databases.yml lvm \
  -e "task_action=create disk=/dev/sdd size=500G name=/var/lib/postgresql"
```

## Bezpieczeństwo

### Tryb dry-run
**Zawsze używaj trybu `-c` (dry-run) przed wykonaniem operacji na produkcji:**

```bash
# Test przed wykonaniem
./run-automation.sh -i inventory/production.yml lvm \
  -e "task_action=create disk=/dev/sdb size=100G name=/data" -c

# Jeśli wszystko OK, wykonaj bez -c
./run-automation.sh -i inventory/production.yml lvm \
  -e "task_action=create disk=/dev/sdb size=100G name=/data"
```

### Walidacja
Moduł automatycznie sprawdza:
- Istnienie dysku przed operacjami
- Czy dysk nie jest używany
- Poprawność parametrów LVM
- Dostępne miejsce na dysku

### Ostrzeżenia
⚠️ **UWAGI BEZPIECZEŃSTWA:**
- Operacje LVM są nieodwracalne
- Zawsze rób backup przed modyfikacją dysków
- Testuj na środowisku testowym
- Sprawdź czy dysk nie zawiera ważnych danych

## Rozwiązywanie problemów

### Błąd: "Dysk nie istnieje"
```bash
# Sprawdź dostępne dyski
lsblk
fdisk -l

# Upewnij się że ścieżka jest poprawna
./run-automation.sh -i inventory/localhost.yml lvm -e "task_action=check"
```

### Błąd: "LVM nie jest zainstalowany"
```bash
# Ubuntu/Debian
sudo apt-get install lvm2

# CentOS/RHEL
sudo yum install lvm2
```

### Błąd: "Brak uprawnień"
```bash
# Sprawdź konfigurację sudo w inventory
cat inventory/production.yml

# Upewnij się że user ma uprawnienia sudo
sudo -l
```

### Sprawdzenie stanu LVM po operacji
```bash
# Volume Groups
sudo vgs

# Logical Volumes  
sudo lvs

# Physical Volumes
sudo pvs

# Punkty montowania
df -h
mount | grep lvm
```

## Logi i monitorowanie

### Lokalizacja logów
- Ansible: `ansible.log` (konfigurowane w ansible.cfg)
- System: `/var/log/syslog` lub `/var/log/messages`
- LVM: `journalctl -u lvm2-*`

### Monitoring użycia
```bash
# Sprawdź użycie wolumenów
df -h

# Status LVM
sudo vgdisplay
sudo lvdisplay

# I/O dysków
iostat -x 1
```

## Integracja z innymi modułami

### Z modułem backup
```bash
# Najpierw utwórz wolumin
./run-automation.sh -i inventory/production.yml lvm \
  -e "task_action=create disk=/dev/sdb size=500G name=/backup"

# Następnie konfiguruj backup
./run-automation.sh -i inventory/production.yml backup \
  -e "task_action=archive source=/var/www dest=/backup/www-$(date +%Y%m%d).tar.gz"
```

### Z modułem install
```bash
# Zainstaluj LVM przed użyciem
./run-automation.sh -i inventory/production.yml install \
  -e "task_action=install packages=lvm2"

# Następnie skonfiguruj dyski
./run-automation.sh -i inventory/production.yml lvm \
  -e "task_action=create disk=/dev/sdb size=100G name=/data"
```

## Najlepsze praktyki

1. **Zawsze testuj na środowisku development**
2. **Używaj spójnych nazw Volume Groups** (np. vg-data, vg-logs)
3. **Dokumentuj topologię dysków** w group_vars
4. **Monitoruj użycie miejsca** (alerty przy >80%)
5. **Regularnie sprawdzaj stan LVM** (vgs, lvs)
6. **Konfiguruj monitoring** dla critical mountpoints
7. **Backup konfiguracji LVM** (`vgcfgbackup`)

## Wsparcie i rozwój

- Dokumentacja: `docs/`
- Przykłady: `EXAMPLES.md`
- Testy: Uruchom z flagą `-c` przed produkcją
- Issues: Sprawdź logi w `ansible.log`