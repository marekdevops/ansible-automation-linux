# MODUŁ USERSLDAP - Zarządzanie Użytkownikami LDAP/AD

## Opis

Moduł `usersldap` umożliwia zarządzanie nadpisaniami (overrides) dla użytkowników LDAP/Active Directory za pomocą narzędzia `sss_override` z pakietu SSSD. Pozwala na zmianę katalogu domowego, shell, UID i GID dla użytkowników domenowych bez modyfikacji katalogu LDAP/AD.

## Funkcje

- ✅ Nadpisywanie katalogów domowych dla użytkowników LDAP/AD
- ✅ Zmiana shell dla użytkowników domenowych
- ✅ Modyfikacja UID/GID
- ✅ Automatyczna instalacja sssd-tools
- ✅ Automatyczny restart SSSD
- ✅ Tworzenie katalogów domowych
- ✅ Tryb pojedynczy i wsadowy (YAML)
- ✅ Weryfikacja zmian (getent + sss_override)
- ✅ Szczegółowe raportowanie

## Wymagania

### System
- SSSD (System Security Services Daemon) - skonfigurowany i działający
- Konfiguracja LDAP/Active Directory w SSSD
- Uprawnienia sudo

### Pakiety
- `sssd-tools` - instalowany automatycznie przez moduł

### Użytkownicy
- Użytkownicy muszą istnieć w LDAP/AD
- Użytkownicy muszą być widoczni przez `getent passwd`

## Użycie

### Podstawowe (pojedynczy użytkownik)

```bash
# Zmiana katalogu domowego
./run-automation.sh usersldap -e "username=jan.kowalski home=/home/jan"

# Zmiana katalogu i shell
./run-automation.sh usersldap -e "username=anna.nowak home=/home/anna shell=/bin/bash"

# Pełna konfiguracja (katalog, shell, UID, GID)
./run-automation.sh usersldap -e "username=piotr.wisniewski home=/home/piotr shell=/bin/bash uid=10001 gid=10001"

# Tylko zmiana UID/GID
./run-automation.sh usersldap -e "username=user1 uid=10005 gid=10005"

# Tylko zmiana shell
./run-automation.sh usersldap -e "username=user2 shell=/bin/zsh"
```

### Tryb wsadowy (plik YAML)

Utwórz plik `vars/usersldap.yml`:

```yaml
---
usersldap_list:
  # Użytkownik z katalogiem domowym
  - username: jan.kowalski
    home: /home/jan
  
  # Użytkownik z katalogiem i shell
  - username: anna.nowak
    home: /home/anna
    shell: /bin/bash
  
  # Użytkownik z pełną konfiguracją
  - username: piotr.wisniewski
    home: /home/piotr
    shell: /bin/bash
    uid: 10001
    gid: 10001
  
  # Użytkownik aplikacji
  - username: tomcat.service
    home: /opt/tomcat
    shell: /bin/bash
    uid: 999
    gid: 999
```

Następnie uruchom:

```bash
./run-automation.sh usersldap -e "@vars/usersldap.yml"
```

### Tryb Check (Dry-run)

```bash
# Sprawdź co zostanie zmienione
./run-automation.sh usersldap -e "username=jan.kowalski home=/home/jan" --check

# Dla wielu użytkowników
./run-automation.sh usersldap -e "@vars/usersldap.yml" --check
```

### Różne środowiska

```bash
# Serwery produkcyjne
./run-automation.sh usersldap -i inventory/production.yml -e "@vars/usersldap.yml"

# Serwery testowe
./run-automation.sh usersldap -i inventory/staging.yml -e "username=test.user home=/home/test"
```

## Parametry

| Parametr | Wymagany | Typ | Opis | Przykład |
|----------|----------|-----|------|----------|
| `username` | **TAK** | string | Nazwa użytkownika LDAP/AD | jan.kowalski |
| `home` | NIE | string | Nowy katalog domowy | /home/jan |
| `shell` | NIE | string | Nowa powłoka | /bin/bash |
| `uid` | NIE | integer | Nowy UID | 10001 |
| `gid` | NIE | integer | Nowy GID | 10001 |

**Uwaga:** Co najmniej jeden z parametrów `home`, `shell`, `uid`, `gid` musi być podany.

## Przykłady Użycia

### Scenariusz 1: Migracja Katalogów Domowych

```bash
# Pojedynczy użytkownik
./run-automation.sh usersldap -e "username=jan.kowalski home=/data/users/jan"

# Grupa użytkowników
cat > vars/migrate_homes.yml << 'EOF'
---
usersldap_list:
  - username: jan.kowalski
    home: /data/users/jan
  - username: anna.nowak
    home: /data/users/anna
  - username: piotr.wisniewski
    home: /data/users/piotr
EOF

./run-automation.sh usersldap -e "@vars/migrate_homes.yml"
```

### Scenariusz 2: Standaryzacja Shell

```bash
# Zmiana shell dla wszystkich deweloperów
cat > vars/dev_shell.yml << 'EOF'
---
usersldap_list:
  - username: dev1
    shell: /bin/bash
  - username: dev2
    shell: /bin/bash
  - username: dev3
    shell: /bin/zsh
EOF

./run-automation.sh usersldap -e "@vars/dev_shell.yml"
```

### Scenariusz 3: Konta Aplikacji

```bash
# Aplikacje z niestandardowymi katalogami
cat > vars/app_users.yml << 'EOF'
---
usersldap_list:
  - username: tomcat.service
    home: /opt/tomcat
    shell: /bin/bash
    uid: 999
    gid: 999
  
  - username: nginx.service
    home: /var/lib/nginx
    shell: /usr/sbin/nologin
    uid: 998
    gid: 998
  
  - username: postgres.service
    home: /var/lib/postgresql
    shell: /bin/bash
    uid: 997
    gid: 997
EOF

./run-automation.sh usersldap -e "@vars/app_users.yml"
```

### Scenariusz 4: Synchronizacja UID/GID

```bash
# Synchronizacja UID/GID między środowiskami
cat > vars/sync_ids.yml << 'EOF'
---
usersldap_list:
  - username: admin1
    uid: 10001
    gid: 10001
  - username: admin2
    uid: 10002
    gid: 10002
  - username: operator1
    uid: 10010
    gid: 10010
EOF

./run-automation.sh usersldap -i inventory/production.yml -e "@vars/sync_ids.yml"
```

## Format Raportu

Po wykonaniu moduł wyświetla szczegółowy raport:

```
==================================================================================
              RAPORT ZARZĄDZANIA UŻYTKOWNIKAMI LDAP/AD (SSS_OVERRIDE)
==================================================================================

[SUMMARY] PODSUMOWANIE:
   Tryb: Multi User
   Przetworzonych użytkowników: 3
   SSSD Tools: Już zainstalowany
   SSSD: Zrestartowano
   Status: Zmiany zastosowane

[USERS] LISTA UŻYTKOWNIKÓW Z NADPISANIAMI:

1. jan.kowalski
   Status: Nadpisanie aktywne
   Getent: OK - użytkownik widoczny
   Szczegóły nadpisania:
     jan.kowalski:*:10001:10001:Jan Kowalski:/home/jan:/bin/bash
   Dane systemowe:
     jan.kowalski:x:10001:10001:Jan Kowalski:/home/jan:/bin/bash

2. anna.nowak
   Status: Nadpisanie aktywne
   Getent: OK - użytkownik widoczny
   Szczegóły nadpisania:
     anna.nowak:*:10002:10002:Anna Nowak:/home/anna:/bin/bash
   Dane systemowe:
     anna.nowak:x:10002:10002:Anna Nowak:/home/anna:/bin/bash

==================================================================================
```

## Jak to działa?

### 1. Sprawdzenie wymagań
- Weryfikacja czy sssd-tools jest zainstalowany
- Instalacja sssd-tools jeśli brak

### 2. Nadpisania SSSD
```bash
# Moduł wykonuje:
sss_override user-add jan.kowalski --home=/home/jan --shell=/bin/bash
```

### 3. Tworzenie katalogów
- Tworzenie katalogu domowego jeśli nie istnieje
- Ustawienie właściciela na użytkownika

### 4. Restart SSSD
```bash
systemctl restart sssd
```

### 5. Weryfikacja
```bash
# Sprawdzenie nadpisania:
sss_override user-show jan.kowalski

# Sprawdzenie w systemie:
getent passwd jan.kowalski
```

## Przydatne Komendy

### Zarządzanie nadpisaniami

```bash
# Wyświetl wszystkie nadpisania
sudo sss_override user-find

# Szczegóły nadpisania użytkownika
sudo sss_override user-show jan.kowalski

# Usuń nadpisanie
sudo sss_override user-del jan.kowalski
sudo systemctl restart sssd

# Wyczyść wszystkie nadpisania (OSTROŻNIE!)
sudo sss_cache -E
sudo systemctl restart sssd
```

### Weryfikacja użytkowników

```bash
# Sprawdź użytkownika w systemie
getent passwd jan.kowalski

# Sprawdź grupy użytkownika
id jan.kowalski

# Test logowania
su - jan.kowalski
```

### Diagnostyka SSSD

```bash
# Status SSSD
sudo systemctl status sssd

# Logi SSSD
sudo journalctl -u sssd -f

# Restart SSSD
sudo systemctl restart sssd

# Cache SSSD
sudo sss_cache -E
```

## Troubleshooting

### Problem: Użytkownik nie istnieje w LDAP

```
ERROR: User not found in LDAP/AD
```

**Rozwiązanie:** Upewnij się że użytkownik istnieje w LDAP/AD i jest widoczny przez `getent passwd username`.

### Problem: sssd-tools nie jest zainstalowany

```
ERROR: sssd-tools package not found
```

**Rozwiązanie:** Moduł automatycznie instaluje sssd-tools. Jeśli instalacja się nie powiedzie, zainstaluj ręcznie:

```bash
# Ubuntu/Debian
sudo apt install sssd-tools

# RHEL/CentOS
sudo yum install sssd-tools
```

### Problem: SSSD nie działa

```
ERROR: SSSD service not running
```

**Rozwiązanie:**

```bash
# Sprawdź status
sudo systemctl status sssd

# Uruchom SSSD
sudo systemctl start sssd

# Sprawdź konfigurację
sudo sssctl config-check
```

### Problem: Katalog domowy nie został utworzony

```
ERROR: Home directory does not exist
```

**Rozwiązanie:** Moduł automatycznie tworzy katalog. Jeśli problem występuje, sprawdź uprawnienia:

```bash
# Ręczne utworzenie
sudo mkdir -p /home/jan
sudo chown jan.kowalski:domain.users /home/jan
sudo chmod 755 /home/jan
```

### Problem: Nadpisanie nie działa

```
WARNING: Override not visible after restart
```

**Rozwiązanie:**

```bash
# Wyczyść cache SSSD
sudo sss_cache -E

# Restart SSSD
sudo systemctl restart sssd

# Weryfikuj
getent passwd jan.kowalski
```

## Bezpieczeństwo

⚠️ **WAŻNE:**

1. **Backup przed zmianami:** Zawsze rób backup konfiguracji SSSD
2. **Testuj na staging:** Testuj zmiany na środowisku testowym
3. **Dokumentuj zmiany:** Zapisuj wszystkie nadpisania w plikach YAML
4. **Weryfikuj po zmianach:** Sprawdź czy użytkownicy mogą się zalogować
5. **Uprawnienia katalogów:** Katalogi domowe muszą mieć odpowiedniego właściciela

## Różnice między `users` a `usersldap`

| Funkcja | `users` | `usersldap` |
|---------|---------|-------------|
| Użytkownicy lokalni | ✅ | ❌ |
| Użytkownicy LDAP/AD | ❌ | ✅ |
| Tworzenie użytkowników | ✅ | ❌ (tylko nadpisania) |
| Zmiana katalogu domowego | ✅ | ✅ |
| Zarządzanie grupami | ✅ | ❌ |
| Wymagane narzędzie | useradd | sss_override |
| Restart usługi | ❌ | ✅ (SSSD) |

## Integracja z innymi modułami

```bash
# 1. Nadpisz katalog dla użytkownika LDAP
./run-automation.sh usersldap -e "username=jan.kowalski home=/home/jan"

# 2. Dodaj uprawnienia sudo
./run-automation.sh sudoers -e "user=jan.kowalski"

# 3. Utwórz LVM dla katalogu domowego
./run-automation.sh lvm -e "task_action=create disk=/dev/sdb size=50G name=/home"
```

## Zobacz także

- [USERS-MODULE.md](USERS-MODULE.md) - Moduł dla użytkowników lokalnych
- [USER-MODULE.md](USER-MODULE.md) - Moduł dla pojedynczych użytkowników
- [SUDOERS-MODULE.md](SUDOERS-MODULE.md) - Konfiguracja uprawnień sudo

## Wsparcie

W razie problemów:
1. Sprawdź czy SSSD działa: `systemctl status sssd`
2. Sprawdź użytkownika: `getent passwd username`
3. Sprawdź nadpisania: `sss_override user-find`
4. Użyj trybu verbose: `-v` lub `-vvv`
5. Sprawdź logi: `journalctl -u sssd -f`
