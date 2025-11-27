# RAPORTINFRA MODULE - Raport infrastruktury serwerów

## Opis
Moduł RAPORTINFRA generuje kompleksowy raport o infrastrukturze serwerów, zbierając kluczowe informacje o sprzęcie i systemie operacyjnym.

## Funkcjonalności

### Zbierane informacje:
- **🖥️ Podstawowe** - Hostname, FQDN, IP, uptime
- **💻 CPU** - Model, liczba rdzeni, vCPU, obciążenie systemu
- **💾 RAM** - Całkowita, wolna, wykorzystanie w %
- **💿 Dyski** - Liczba, pojemność, model każdego dysku
- **🐧 System operacyjny** - Dystrybucja, wersja, kernel, architektura
- **🌐 Sieć** - Liczba interfejsów, główny adres IP

### Formaty wyjściowe:
- **TEXT** (domyślny) - Czytelny, sformatowany raport
- **JSON** - Format strukturalny dla automatyzacji
- **CSV** - Format dla wielu serwerów, łatwy do analizy w Excel

## Wymagania

### Pakiety systemu
- Brak specjalnych wymagań (używa Ansible Facts)
- Opcjonalnie: `bc` dla precyzyjnych obliczeń rozmiaru dysków

### Uprawnienia
- **NIE wymaga sudo** - Moduł działa bez uprawnień root
- Działa na standardowych uprawnieniach użytkownika

## Użycie

### Podstawowa składnia
```bash
./run-automation.sh raportinfra -i <inventory>
```

### Format tekstowy (domyślny)
```bash
# Pojedynczy serwer
./run-automation.sh raportinfra -i inventory/localhost.yml

# Grupa serwerów produkcyjnych
./run-automation.sh raportinfra -i inventory/production.yml

# Wszystkie serwery
./run-automation.sh raportinfra -i inventory/hosts.yml
```

### Format JSON
```bash
# Raport w formacie JSON
./run-automation.sh raportinfra -i inventory/production.yml -e "format=json"

# JSON dla pojedynczego serwera
./run-automation.sh raportinfra -i inventory/localhost.yml -e "format=json"
```

### Format CSV
```bash
# CSV dla wielu serwerów (łatwy import do Excel)
./run-automation.sh raportinfra -i inventory/production.yml -e "format=csv"

# CSV dla wszystkich środowisk
./run-automation.sh raportinfra -i inventory/hosts.yml -e "format=csv"
```

## Przykłady zastosowania

### Scenariusz 1: Audyt infrastruktury
```bash
# Zbierz informacje o wszystkich serwerach produkcyjnych
./run-automation.sh raportinfra -i inventory/production.yml

# Zapisz do pliku
./run-automation.sh raportinfra -i inventory/production.yml > raport-produkcja-$(date +%Y%m%d).txt
```

### Scenariusz 2: Monitorowanie zasobów
```bash
# Sprawdź zasoby serwerów aplikacyjnych
./run-automation.sh raportinfra -i inventory/production.yml -l appservers

# Sprawdź tylko serwery baz danych
./run-automation.sh raportinfra -i inventory/production.yml -l databases
```

### Scenariusz 3: Eksport do analizy
```bash
# Wygeneruj CSV dla analizy w Excel
./run-automation.sh raportinfra -i inventory/hosts.yml -e "format=csv" > infra-report.csv

# JSON dla automatyzacji/API
./run-automation.sh raportinfra -i inventory/production.yml -e "format=json" > infra.json
```

### Scenariusz 4: Porównanie środowisk
```bash
# Development
./run-automation.sh raportinfra -i inventory/development.yml > dev-infra.txt

# Staging
./run-automation.sh raportinfra -i inventory/staging.yml > staging-infra.txt

# Production
./run-automation.sh raportinfra -i inventory/production.yml > prod-infra.txt

# Porównaj różnice
diff dev-infra.txt prod-infra.txt
```

## Przykładowy output

### Format TEXT
```
==================================================================================
                    📊 RAPORT INFRASTRUKTURY SERWERA
==================================================================================

🖥️  INFORMACJE PODSTAWOWE:
   Hostname: web-server-01
   FQDN: web-server-01.example.com
   IP: 192.168.1.100
   Uptime: up 15 days, 3 hours, 25 minutes

💻 PROCESOR (CPU):
   Model: Intel(R) Xeon(R) CPU E5-2680 v4 @ 2.40GHz
   Rdzenie fizyczne: 8
   vCPU: 16
   Wątki na rdzeń: 2
   Obciążenie: 2.5 (1min) | 2.1 (5min) | 1.8 (15min)

💾 PAMIĘĆ RAM:
   Całkowita: 32.00 GB (32768 MB)
   Wolna: 8.50 GB (8704 MB)
   Wykorzystanie: 73.4%

💿 DYSKI:
   Liczba dysków: 2
   Całkowita pojemność: ~500.00 GB
   Lista dysków:
   - sda: 250.00 GB (Samsung SSD 850)
   - sdb: 250.00 GB (Samsung SSD 850)

🐧 SYSTEM OPERACYJNY:
   Dystrybucja: Ubuntu 22.04
   Kernel: 5.15.0-75-generic
   Architektura: x86_64

🌐 SIEĆ:
   Interfejsy: 3
   IPv4: 192.168.1.100

==================================================================================
```

### Format JSON
```json
{
  "hostname": "web-server-01",
  "fqdn": "web-server-01.example.com",
  "ip_address": "192.168.1.100",
  "uptime": "up 15 days, 3 hours, 25 minutes",
  "cpu": {
    "model": "Intel(R) Xeon(R) CPU E5-2680 v4 @ 2.40GHz",
    "cores": 8,
    "vcpus": 16,
    "threads_per_core": 2,
    "load_1min": 2.5,
    "load_5min": 2.1,
    "load_15min": 1.8
  },
  "ram": {
    "total_gb": 32.00,
    "free_gb": 8.50,
    "used_percent": 73.4
  },
  "disks": {
    "count": 2,
    "total_size_gb": 500.00,
    "details": ["sda", "sdb"]
  },
  "os": {
    "distribution": "Ubuntu",
    "version": "22.04",
    "kernel": "5.15.0-75-generic",
    "architecture": "x86_64"
  }
}
```

### Format CSV
```
Hostname,IP,OS,CPU_Cores,CPU_vCPUs,RAM_GB,Disk_Count,Total_Disk_GB,Uptime
web-server-01,192.168.1.100,Ubuntu 22.04,8,16,32.00,2,500.00,up 15 days
db-server-01,192.168.1.101,Ubuntu 22.04,16,32,64.00,4,2000.00,up 30 days
app-server-01,192.168.1.102,CentOS 8,8,16,16.00,2,250.00,up 5 days
```

## Integracja z innymi narzędziami

### Excel / Google Sheets
```bash
# Wygeneruj CSV
./run-automation.sh raportinfra -i inventory/production.yml -e "format=csv" > infra.csv

# Otwórz w Excel i stwórz wykresy
```

### Monitoring / Grafana
```bash
# Generuj JSON dla Grafana
./run-automation.sh raportinfra -i inventory/production.yml -e "format=json" | \
  curl -X POST -H "Content-Type: application/json" -d @- http://monitoring/api/infra
```

### Cron job (codzienne raporty)
```bash
# Dodaj do crontab
0 2 * * * cd /path/to/ansible && ./run-automation.sh raportinfra -i inventory/production.yml > /backup/reports/infra-$(date +\%Y\%m\%d).txt
```

### Skrypt porównawczy
```bash
#!/bin/bash
# compare-environments.sh

./run-automation.sh raportinfra -i inventory/development.yml -e "format=json" > dev.json
./run-automation.sh raportinfra -i inventory/staging.yml -e "format=json" > staging.json
./run-automation.sh raportinfra -i inventory/production.yml -e "format=json" > prod.json

# Porównaj zasoby
echo "=== PORÓWNANIE ZASOBÓW ==="
jq -r '.ram.total_gb' dev.json staging.json prod.json
```

## Najlepsze praktyki

1. **Regularne raporty** - Uruchamiaj raz dziennie dla historii
2. **Backup raportów** - Zachowuj raporty dla audytu
3. **Format według potrzeb** - TEXT dla ludzi, JSON dla automatyzacji, CSV dla analizy
4. **Grupowanie** - Używaj `-l` do raportowania konkretnych grup serwerów
5. **Dokumentacja zmian** - Porównuj raporty przed i po zmianach infrastruktury

## Rozwiązywanie problemów

### Brak informacji o dyskach
```bash
# Sprawdź czy bc jest zainstalowane
sudo apt-get install bc

# Sprawdź uprawnienia do /dev
ls -la /dev/sd* /dev/nvme*
```

### Nieprawidłowy rozmiar dysków
```bash
# Sprawdź ręcznie
lsblk -b
ansible localhost -m setup -a 'filter=ansible_devices'
```

### Brak uptime
```bash
# Upewnij się że komenda uptime istnieje
which uptime
```

## Wsparcie i rozwój

- Dokumentacja: `docs/RAPORTINFRA-MODULE.md`
- Przykłady: `EXAMPLES.md`
- Moduł nie wymaga sudo - bezpieczny w użyciu
- Format wyjścia łatwy do parsowania i automatyzacji

## Changelog

- **v1.0** (2025-11-27) - Pierwsza wersja modułu
  - Format TEXT, JSON, CSV
  - Informacje o CPU, RAM, dyskach, OS, sieci
  - Brak wymagania sudo
  - Filtrowanie loop devices i device mapper