# Moduł BACKUP - Zarządzanie Archiwami i Kopiami Zapasowymi

## Opis
Moduł `backup` umożliwia tworzenie i przywracanie kopii zapasowych między serwerami zdalnymi a lokalną maszyną. Oferuje dwie główne funkcje: `archive` (archiwizacja) i `extract` (ekstraktowanie).

## Funkcjonalności

### 🗜️ ARCHIVE - Tworzenie kopii zapasowej
- Archiwizuje katalog ze zdalnego serwera
- Sprawdza dostępne miejsce na dysku
- Tworzy archiwum tar.gz z kompresją
- Pobiera archiwum na localhost
- Automatyczne nazewnictwo z hostname i timestamp

### 📂 EXTRACT - Przywracanie z kopii
- Wysyła archiwum z localhost na zdalny serwer
- Sprawdza zawartość archiwum przed ekstraktowaniem
- Rozpakuje do wskazanego katalogu
- Automatyczne czyszczenie plików tymczasowych

## Użycie

### Parametry podstawowe

| Parametr | Wymagany | Opis |
|----------|----------|------|
| `task_action` | ✅ | Akcja do wykonania: `archive` lub `extract` |
| `source` | ✅ | Źródło (katalog dla archive, plik dla extract) |
| `target` | ✅ | Cel (katalog lokalny dla archive, zdalny dla extract) |

### Parametry opcjonalne

| Parametr | Domyślna wartość | Opis |
|----------|------------------|------|
| `min_space` | `1` | Minimalne wolne miejsce w GB |
| `compression` | `6` | Poziom kompresji tar.gz (1-9) |
| `exclude` | `*.log,*.tmp,cache/*` | Wzorce plików do wykluczenia |

## Przykłady użycia

### 📦 Tworzenie kopii zapasowej (ARCHIVE)

```bash
# Podstawowa archiwizacja
./run-automation.sh backup -e "task_action=archive source=/opt/tomcat target=./backups"

# Z niestandardowym wykluczeniem
./run-automation.sh backup -e "task_action=archive source=/var/www exclude='*.log,cache/*,*.tmp' target=./web-backup"

# Z wyższą kompresją
./run-automation.sh backup -e "task_action=archive source=/database compression=9 target=./db-backup"

# Test (dry-run)
./run-automation.sh backup -e "task_action=archive source=/etc target=./config-backup" -c
```

#### Rezultat archivizacji:
```
Źródło: /opt/tomcat (na zdalnym serwerze)
↓
Archiwum: ./backups/tomcat_server1_1760439251.tar.gz (na localhost)
```

### 📂 Przywracanie z kopii (EXTRACT)

```bash
# Podstawowe przywracanie
./run-automation.sh backup -e "task_action=extract source=./backups/tomcat_server1_123456.tar.gz target=/opt/tomcat"

# Przywracanie do innego katalogu
./run-automation.sh backup -e "task_action=extract source=./backups/website.tar.gz target=/var/www/new-site"

# Test (dry-run)
./run-automation.sh backup -e "task_action=extract source=./backup.tar.gz target=/tmp/restore-test" -c
```

#### Rezultat ekstraktowania:
```
Archiwum: ./backups/tomcat.tar.gz (na localhost)
↓
Cel: /opt/tomcat (na zdalnym serwerze)
```

## Nazewnictwo plików

Archiwum tworzone przez `archive` ma format:
```
{nazwa_katalogu}_{hostname}_{timestamp}.tar.gz
```

**Przykłady:**
- `tomcat_server1_1760439251.tar.gz`
- `docs_localhost_1760439251.tar.gz`
- `www_production-web_1760439251.tar.gz`

## Workflow archivizacji (ARCHIVE)

1. **Walidacja** - Sprawdza czy katalog źródłowy istnieje
2. **Analiza miejsca** - Oblicza rozmiar i sprawdza dostępne miejsce
3. **Tworzenie katalogu** - Tworzy katalog docelowy na localhost
4. **Archiwizacja** - Tworzy tar.gz na zdalnym serwerze
5. **Transfer** - Pobiera archiwum na localhost
6. **Czyszczenie** - Usuwa tymczasowe pliki ze zdalnego serwera

## Workflow ekstraktowania (EXTRACT)

1. **Walidacja** - Sprawdza czy plik archiwum istnieje lokalnie
2. **Transfer** - Wysyła archiwum na zdalny serwer
3. **Analiza** - Sprawdza zawartość archiwum
4. **Przygotowanie** - Tworzy katalog docelowy
5. **Ekstraktowanie** - Rozpakuje archiwum
6. **Czyszczenie** - Usuwa tymczasowe pliki

## Przykłady dla różnych scenariuszy

### Kopia zapasowa aplikacji
```bash
# Tomcat
./run-automation.sh backup -e "task_action=archive source=/opt/tomcat target=./app-backups"

# Nginx/Apache config
./run-automation.sh backup -e "task_action=archive source=/etc/nginx target=./config-backups"

# Bazy danych (katalogi)
./run-automation.sh backup -e "task_action=archive source=/var/lib/mysql target=./db-backups"
```

### Migracja między serwerami
```bash
# 1. Archiwizuj z serwera źródłowego
./run-automation.sh -i inventory/source-server.yml backup -e "task_action=archive source=/app target=./migration"

# 2. Przywróć na serwer docelowy  
./run-automation.sh -i inventory/target-server.yml backup -e "task_action=extract source=./migration/app_source_123.tar.gz target=/app"
```

### Regularne kopie zapasowe
```bash
# Skrypt crontab
0 2 * * * /path/to/run-automation.sh backup -e "task_action=archive source=/important-data target=./daily-backups"
```

## Informacje zwrotne

### Output archivizacji:
```
=== ARCHIWIZACJA ZAKOŃCZONA ===
Źródło: /opt/tomcat (2.5 GB)
Archiwum: ./backups/tomcat_server1_123456.tar.gz
Rozmiar archiwum: 890.5 MB
Kompresja: 64.4%
Status: ✅ Sukces
```

### Output ekstraktowania:
```
=== EKSTRAKTOWANIE ZAKOŃCZONE ===
Archiwum: ./backups/tomcat.tar.gz
Cel: /opt/tomcat
Wyekstraktowano: 1247 plików/katalogów
Dostępne miejsce: 15.2 GB
Status: ✅ Sukces
```

## Obsługa błędów

Moduł automatycznie sprawdza:
- ✅ Istnienie katalogów/plików źródłowych
- ✅ Dostępne miejsce na dysku
- ✅ Uprawnienia do katalogów
- ✅ Integralność archiwów
- ✅ Wystarczające miejsce dla ekstraktowania

## Integracja z inventory

```bash
# Kopia z serwera produkcyjnego
./run-automation.sh -i inventory/production.yml backup -e "task_action=archive source=/app target=./prod-backups"

# Przywracanie na staging
./run-automation.sh -i inventory/staging.yml backup -e "task_action=extract source=./prod-backups/app_prod_123.tar.gz target=/app"
```

## Bezpieczeństwo

- 🔒 Wszystkie operacje wymagają uprawnień `sudo`
- 🔒 Pliki tymczasowe są automatycznie usuwane
- 🔒 Walidacja ścieżek przed operacjami
- 🔒 Tryb dry-run (`-c`) do bezpiecznego testowania

## Optymalizacja

### Wykluczanie niepotrzebnych plików:
```bash
./run-automation.sh backup -e "task_action=archive source=/app exclude='*.log,*.tmp,node_modules/*,cache/*' target=./clean-backup"
```

### Wysoka kompresja dla rzadkich backupów:
```bash
./run-automation.sh backup -e "task_action=archive source=/archive compression=9 target=./compressed-backup"
```

## Zobacz także

- [INSTALL-MODULE.md](INSTALL-MODULE.md) - Instalacja pakietów
- [USER-MODULE.md](USER-MODULE.md) - Zarządzanie użytkownikami
- [SUDOERS-MODULE.md](SUDOERS-MODULE.md) - Konfiguracja uprawnień sudo
- [INVENTORY-USAGE.md](INVENTORY-USAGE.md) - Zarządzanie inventory