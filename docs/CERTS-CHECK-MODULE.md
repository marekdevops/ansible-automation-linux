# Moduł CERTS-CHECK - Dokumentacja

## Opis
Moduł `certs-check` służy do sprawdzania certyfikatów w plikach bundle (PEM). Wyszukuje certyfikaty pasujące do podanej domeny i wyświetla szczegóły: CN, wystawcę, SAN, daty ważności, algorytm podpisu.

Bazuje na skrypcie `cert_info.sh` - rozdziela bundle na pojedyncze certyfikaty i analizuje każdy z osobna.

## Podstawowe użycie

### Składnia
```bash
# Domyślny bundle RHEL (/etc/pki/tls/certs/ca-bundle.crt)
./run-automation.sh certs-check -e "domain=DOMENA"

# Własny plik bundle
./run-automation.sh certs-check -e "domain=DOMENA bundle=/path/to/bundle.pem"
```

### Wymagane parametry
- `domain` - nazwa domeny do wyszukania (np. `abc.com`, `*.abc.com`)

### Opcjonalne parametry
- `bundle` - ścieżka do pliku bundle (domyślnie: `/etc/pki/tls/certs/ca-bundle.crt`)
- `warn_days` - liczba dni przed wygaśnięciem dla ostrzeżenia (domyślnie: `30`)

## Przykłady użycia

### 1. Podstawowe sprawdzenie (domyślny bundle RHEL)
```bash
./run-automation.sh certs-check -e "domain=abc.com" -l test-server
```

### 2. Własny plik bundle
```bash
./run-automation.sh certs-check -e "domain=abc.com bundle=/etc/ssl/certs/my-bundle.pem" -l test-server
```

### 3. Zmiana progu ostrzeżenia
```bash
# Ostrzegaj jeśli certyfikat wygasa w ciągu 60 dni
./run-automation.sh certs-check -e "domain=abc.com warn_days=60" -l test-server
```

### 4. Sprawdzenie na wielu serwerach
```bash
./run-automation.sh certs-check -e "domain=company.com" -i inventory/production.yml
```

### 5. Dry-run
```bash
./run-automation.sh certs-check -e "domain=abc.com" -l test-server -c
```

## Wyświetlane informacje

Dla każdego znalezionego certyfikatu:
- **CN (Common Name)** - nazwa główna certyfikatu
- **Wystawca (Issuer)** - kto wystawił certyfikat
- **Serial** - numer seryjny
- **Ważny od / do** - daty ważności
- **Pozostało dni** - ile dni do wygaśnięcia
- **Status** - wygasły / wkrótce wygaśnie / OK
- **SAN** - Subject Alternative Names
- **Key Usage** - użycie klucza
- **Algorytm** - algorytm podpisu

## Przykładowy output

```
╔══════════════════════════════════════════════════════════════════════════════════════════╗
║  🔍 ANALIZA CERTYFIKATÓW DLA: abc.com
╠══════════════════════════════════════════════════════════════════════════════════════════╣
║  📁 Bundle: /etc/pki/tls/certs/ca-bundle.crt
║  📊 Certyfikatów w bundlu: 142
║  🎯 Znalezionych dla domeny: 2
╠══════════════════════════════════════════════════════════════════════════════════════════╣
║
║  🎯 CERTYFIKAT #1
║  ├── 👤 CN: *.abc.com
║  ├── 🏢 Wystawca: DigiCert SHA2 Extended Validation Server CA
║  ├── 🔢 Serial: 0A:1B:2C:3D:4E:5F
║  ├── 📅 Ważny od: Jan 15 00:00:00 2024 GMT
║  ├── 📅 Ważny do: Jan 15 23:59:59 2026 GMT
║  ├── ⏳ Pozostało: 340 dni ✅
║  ├── 🌐 SAN: DNS:*.abc.com, DNS:abc.com
║  ├── 🔑 Key Usage: Digital Signature, Key Encipherment
║  └── 🔐 Algorytm: sha256WithRSAEncryption
║
╚══════════════════════════════════════════════════════════════════════════════════════════╝
```

## Statusy certyfikatów

| Status | Ikona | Opis |
|--------|-------|------|
| VALID | ✅ | Certyfikat ważny, więcej niż `warn_days` do wygaśnięcia |
| EXPIRING_SOON | ⚠️ | Certyfikat wygasa w ciągu `warn_days` dni |
| EXPIRED | ⛔ | Certyfikat już wygasł |

## Jak to działa

1. **Rozdzielenie bundla** - plik PEM jest dzielony na pojedyncze certyfikaty (po znacznikach BEGIN/END CERTIFICATE)
2. **Dopasowanie nazwy** - dla każdego certyfikatu sprawdzane jest:
   - CN (Common Name) w Subject
   - DNS entries w Subject Alternative Names
   - Wildcard patterns (*.domain.com)
3. **Analiza** - dla pasujących certyfikatów wyciągane są szczegóły przez openssl
4. **Wyświetlenie** - czytelny raport z informacjami o certyfikatach

## Domyślne lokalizacje bundli

| System | Ścieżka |
|--------|---------|
| RHEL/CentOS | `/etc/pki/tls/certs/ca-bundle.crt` |
| Debian/Ubuntu | `/etc/ssl/certs/ca-certificates.crt` |
| Własne | Dowolna ścieżka do pliku PEM |

## Rozwiązywanie problemów

### Brak wyników
- Sprawdź czy domena jest poprawna
- Spróbuj użyć części nazwy (np. `example` zamiast `www.example.com`)
- Sprawdź czy bundle zawiera szukane certyfikaty

### Błąd "plik bundla nie istnieje"
- Sprawdź ścieżkę do bundla
- Na Debian/Ubuntu użyj: `bundle=/etc/ssl/certs/ca-certificates.crt`

### Błąd "openssl not found"
```bash
# RHEL/CentOS
yum install openssl

# Debian/Ubuntu
apt install openssl
```

## Powiązane
- Oryginalny skrypt: `cert_info.sh` (bash-smieci)
