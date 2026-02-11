# Moduł CERTS-CHECK - Dokumentacja

## Opis
Moduł `certs-check` służy do sprawdzania certyfikatów maszynowych zainstalowanych na serwerach Linux. Wyszukuje certyfikaty pasujące do podanej domeny i wyświetla szczegóły: CN, SAN, datę wygaśnięcia.

## Podstawowe użycie

### Składnia
```bash
./run-automation.sh certs-check -e "domain=DOMENA"
```

### Wymagane parametry
- `domain` - nazwa domeny do wyszukania (np. `abc.com`)

### Opcjonalne parametry
- `warn_days` - liczba dni przed wygaśnięciem dla ostrzeżenia (domyślnie: `30`)

## Przeszukiwane lokalizacje
Moduł przeszukuje standardowe lokalizacje certyfikatów w RHEL/CentOS:
- `/etc/pki/tls/certs`
- `/etc/pki/ca-trust/source/anchors`
- `/etc/ssl/certs`

## Wyświetlane informacje
Dla każdego znalezionego certyfikatu:
- **Ścieżka pliku** - lokalizacja certyfikatu
- **CN (Common Name)** - nazwa główna certyfikatu
- **SAN (Subject Alternative Names)** - alternatywne nazwy
- **Data wygaśnięcia** - kiedy certyfikat wygasa
- **Pozostałe dni** - ile dni do wygaśnięcia
- **Status** - wygasły / wkrótce wygaśnie / OK

## Przykłady użycia

### 1. Podstawowe sprawdzenie
```bash
# Znajdź certyfikaty dla domeny abc.com
./run-automation.sh certs-check -e "domain=abc.com"
```

### 2. Sprawdzenie na konkretnym hoście
```bash
./run-automation.sh certs-check -e "domain=abc.com" -l test-server
```

### 3. Zmiana progu ostrzeżenia
```bash
# Ostrzegaj jeśli certyfikat wygasa w ciągu 60 dni
./run-automation.sh certs-check -e "domain=abc.com warn_days=60"
```

### 4. Sprawdzenie wielu domen
```bash
# Uruchom dla każdej domeny osobno
./run-automation.sh certs-check -e "domain=abc.com" -l prod-servers
./run-automation.sh certs-check -e "domain=xyz.com" -l prod-servers
```

### 5. Sprawdzenie na wszystkich serwerach
```bash
./run-automation.sh certs-check -e "domain=company.com" -i inventory/production.yml
```

## Przykładowy output

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    CERTYFIKATY DLA DOMENY: abc.com
╠══════════════════════════════════════════════════════════════════════════════╣
║
║  📄 PLIK: /etc/pki/tls/certs/wildcard.abc.com.crt
║  ├── CN: *.abc.com
║  ├── SAN: DNS:*.abc.com, DNS:abc.com
║  ├── Wygasa: Dec 15 23:59:59 2025 GMT
║  └── Pozostało: 312 dni ✅
║
║  📄 PLIK: /etc/pki/tls/certs/old-cert.crt
║  ├── CN: app.abc.com
║  ├── SAN: DNS:app.abc.com
║  ├── Wygasa: Mar 01 12:00:00 2024 GMT
║  └── Pozostało: -45 dni ⛔ WYGASŁ!
║
╚══════════════════════════════════════════════════════════════════════════════╝
```

## Statusy certyfikatów

| Status | Opis |
|--------|------|
| ✅ | Certyfikat ważny, więcej niż `warn_days` do wygaśnięcia |
| ⚠️ WKRÓTCE WYGAŚNIE! | Certyfikat wygasa w ciągu `warn_days` dni |
| ⛔ WYGASŁ! | Certyfikat już wygasł |

## Jak to działa

1. Moduł przeszukuje katalogi z certyfikatami
2. Dla każdego pliku `.crt`, `.pem`, `.cert`, `.cer`:
   - Sprawdza czy to certyfikat X.509
   - Wyciąga CN i SAN
   - Porównuje z podaną domeną (uwzględnia wildcard `*`)
3. Wyświetla pasujące certyfikaty z datami wygaśnięcia

## Wzorce dopasowania

Moduł szuka certyfikatów zawierających:
- `*.domain.com` (wildcard)
- `domain.com` (dokładne dopasowanie)
- `subdomain.domain.com` (subdomeny)

## Rozwiązywanie problemów

### Brak wyników
- Sprawdź czy domena jest poprawna
- Sprawdź czy certyfikaty są w standardowych lokalizacjach
- Uruchom z verbose: `./run-automation.sh certs-check -e "domain=abc.com" -v`

### Błąd "openssl not found"
```bash
# RHEL/CentOS
yum install openssl

# Debian/Ubuntu
apt install openssl
```

## Automatyzacja monitoringu

Możesz użyć tego modułu w cron do regularnego sprawdzania certyfikatów:

```bash
# Sprawdzaj co tydzień i zapisuj wynik
0 0 * * 0 /path/to/run-automation.sh certs-check -e "domain=abc.com" > /var/log/cert-check.log 2>&1
```

## Powiązane moduły
- Brak powiązanych modułów
