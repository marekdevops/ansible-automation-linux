# MODUŁ USERS - Zaawansowane Zarządzanie Użytkownikami

## Opis

Moduł `users` umożliwia zaawansowane zarządzanie użytkownikami systemowymi w trybie pojedynczym lub wsadowym. W przeciwieństwie do modułu `user`, który obsługuje tylko pojedynczych użytkowników, moduł `users` może przetwarzać wiele użytkowników jednocześnie z pliku konfiguracyjnego YAML.

## Funkcje

- ✅ Tworzenie użytkowników systemowych
- ✅ Dodawanie użytkowników do grup (pojedynczych lub wielu)
- ✅ Modyfikacja katalogów domowych
- ✅ Konfiguracja powłoki (shell)
- ✅ Tryb pojedynczy (extra vars) i wsadowy (YAML)
- ✅ Tworzenie użytkowników systemowych (system users)
- ✅ Usuwanie użytkowników
- ✅ Automatyczne tworzenie grup jeśli nie istnieją
- ✅ Szczegółowe raportowanie

## Wymagania

- **Obowiązkowe:**
  - `username` - nazwa użytkownika (pojedynczy tryb)
  - `users_list` - lista użytkowników (tryb wsadowy)

- **Opcjonalne:**
  - `groups` - lista grup oddzielona przecinkami
  - `home` - katalog domowy użytkownika
  - `shell` - powłoka (domyślnie: /bin/bash)
  - `state` - stan (present/absent, domyślnie: present)
  - `create_home` - czy tworzyć katalog domowy (domyślnie: true)
  - `system` - czy to użytkownik systemowy (domyślnie: false)
  - `comment` - komentarz/opis użytkownika

## Użycie

### Tryb Pojedynczy (Extra Vars)

```bash
# Podstawowe utworzenie użytkownika
./run-automation.sh users -e "username=jan"

# Użytkownik z grupami
./run-automation.sh users -e "username=jan groups=docker,wheel"

# Użytkownik z niestandardowym katalogiem
./run-automation.sh users -e "username=tomcat home=/opt/tomcat"

# Użytkownik z pełną konfiguracją
./run-automation.sh users -e "username=dbadmin home=/var/lib/dbadmin groups=dba,sudo shell=/bin/bash"

# Dodanie istniejącego użytkownika do nowych grup
./run-automation.sh users -e "username=jan groups=docker,sudo"

# Zmiana katalogu domowego
./run-automation.sh users -e "username=jan home=/home/newjan"

# Użytkownik systemowy
./run-automation.sh users -e "username=nginx system=true create_home=false shell=/usr/sbin/nologin"

# Usunięcie użytkownika
./run-automation.sh users -e "username=olduser state=absent"
```

### Tryb Wsadowy (Plik YAML)

Utwórz plik `vars/users.yml`:

```yaml
---
users_list:
  # Użytkownik z domyślnymi ustawieniami
  - username: jan
    comment: "Jan Kowalski - Developer"
  
  # Użytkownik z grupami
  - username: piotr
    groups: docker,wheel
    comment: "Piotr Nowak - DevOps"
  
  # Użytkownik z niestandardowym katalogiem
  - username: tomcat
    home: /opt/tomcat
    shell: /bin/bash
    groups: webadmin
    system: true
    comment: "Tomcat Application User"
  
  # Użytkownik z wieloma opcjami
  - username: dbadmin
    home: /var/lib/dbadmin
    shell: /bin/bash
    groups: dba,sudo
    create_home: true
    comment: "Database Administrator"
  
  # Użytkownik systemowy
  - username: nginx
    system: true
    create_home: false
    shell: /usr/sbin/nologin
    comment: "Nginx Web Server"
  
  # Użytkownik do usunięcia
  - username: olduser
    state: absent
```

Następnie uruchom:

```bash
./run-automation.sh users -e "@vars/users.yml"
```

### Tryb Check (Dry-run)

```bash
# Sprawdź co zostanie zmienione bez faktycznej modyfikacji
./run-automation.sh users -e "username=jan groups=docker" --check

# Sprawdź zmiany dla wielu użytkowników
./run-automation.sh users -e "@vars/users.yml" --check
```

### Określony Inventory

```bash
# Dla serwerów produkcyjnych
./run-automation.sh users -i inventory/production.yml -e "username=jan groups=docker"

# Dla serwerów staging
./run-automation.sh users -i inventory/staging.yml -e "@vars/users.yml"
```

## Przykłady Użycia

### Scenariusz 1: Tworzenie Użytkownika Aplikacji

```bash
# Utworzenie użytkownika dla Tomcat
./run-automation.sh users -e "username=tomcat home=/opt/tomcat groups=webadmin shell=/bin/bash comment='Tomcat Application User'"
```

### Scenariusz 2: Dodanie Deweloperów

```yaml
# vars/developers.yml
users_list:
  - username: jan
    groups: docker,wheel,developers
    comment: "Jan Kowalski - Backend Developer"
  
  - username: anna
    groups: docker,developers
    comment: "Anna Nowak - Frontend Developer"
  
  - username: piotr
    groups: docker,wheel,sudo,developers
    comment: "Piotr Wiśniewski - DevOps Lead"
```

```bash
./run-automation.sh users -e "@vars/developers.yml"
```

### Scenariusz 3: Użytkownicy Systemowi

```bash
# Nginx
./run-automation.sh users -e "username=nginx system=true create_home=false shell=/usr/sbin/nologin"

# PostgreSQL
./run-automation.sh users -e "username=postgres home=/var/lib/postgresql groups=postgres system=true"
```

### Scenariusz 4: Reorganizacja Użytkowników

```bash
# Przeniesienie użytkownika do nowego katalogu
./run-automation.sh users -e "username=jan home=/home/users/jan"

# Dodanie do nowych grup
./run-automation.sh users -e "username=jan groups=docker,k8s,developers"
```

### Scenariusz 5: Czyszczenie Starych Użytkowników

```yaml
# vars/cleanup.yml
users_list:
  - username: olddev1
    state: absent
  - username: olddev2
    state: absent
  - username: testuser
    state: absent
```

```bash
./run-automation.sh users -e "@vars/cleanup.yml"
```

## Format Raportu

Po wykonaniu moduł wyświetla szczegółowy raport:

```
==================================================================================
                       RAPORT ZARZĄDZANIA UŻYTKOWNIKAMI
==================================================================================

[SUMMARY] PODSUMOWANIE:
   Tryb: Multi User
   Przetworzonych użytkowników: 4
   Status: Zmiany zastosowane

[USERS] LISTA UŻYTKOWNIKÓW:

1. jan
   Stan: Utworzony
   UID: 1001
   GID: 1001
   Katalog: /home/jan
   Shell: /bin/bash
   Grupy: jan docker wheel

2. tomcat
   Stan: Utworzony
   UID: 999
   GID: 999
   Katalog: /opt/tomcat
   Shell: /bin/bash
   Grupy: tomcat webadmin

3. dbadmin
   Stan: Zaktualizowany
   UID: 1002
   GID: 1002
   Katalog: /var/lib/dbadmin
   Shell: /bin/bash
   Grupy: dbadmin dba sudo

4. olduser
   Stan: Usunięty

==================================================================================
```

## Różnice między `user` a `users`

| Funkcja | `user` | `users` |
|---------|--------|---------|
| Pojedynczy użytkownik | ✅ | ✅ |
| Wielu użytkowników | ❌ | ✅ |
| Plik YAML | ❌ | ✅ |
| Sudo | ✅ | ❌* |
| Klucze SSH | ✅ | ❌* |
| Hasła | ✅ | ❌* |
| Automatyczne tworzenie grup | ❌ | ✅ |
| Szczegółowy raport | Podstawowy | Zaawansowany |

*Dla sudo, kluczy SSH i haseł użyj osobnych modułów: `sudoers`, `ssh-keys` (jeśli dostępny)

## Najlepsze Praktyki

1. **Używaj plików YAML dla wielu użytkowników** - łatwiejsze zarządzanie i wersjonowanie
2. **Zawsze testuj z --check** przed faktycznymi zmianami
3. **Dokumentuj użytkowników** poprzez pole `comment`
4. **Grupuj użytkowników logicznie** (developers, admins, apps)
5. **Użytkownicy systemowi** powinni mieć `system: true` i `shell: /usr/sbin/nologin`
6. **Katalogi aplikacji** powinny być poza /home (np. /opt, /var/lib)
7. **Wersjonuj pliki YAML** w systemie kontroli wersji

## Troubleshooting

### Problem: Grupa nie istnieje

```
ERROR: Group 'docker' does not exist
```

**Rozwiązanie:** Moduł automatycznie tworzy grupy. Jeśli błąd występuje, upewnij się że masz uprawnienia sudo.

### Problem: Katalog już istnieje

```
ERROR: Home directory already exists
```

**Rozwiązanie:** Moduł automatycznie przypisuje właściciela. Jeśli problem występuje, sprawdź uprawnienia.

### Problem: Nie można zmienić katalogu domowego

**Rozwiązanie:** Użytkownik nie może być zalogowany. Wyloguj użytkownika przed zmianą.

### Problem: Unicode w komentarzach

```
ERROR: Invalid characters in comment
```

**Rozwiązanie:** Użyj cudzysłowów: `comment="Jan Kowalski - ąćęłńóśźż"`

## Bezpieczeństwo

⚠️ **WAŻNE:**
- Moduł wymaga uprawnień sudo (become: true)
- Nie przechowuj haseł w plaintext w plikach YAML
- Użyj Ansible Vault dla wrażliwych danych
- Regularnie przeglądaj listę użytkowników
- Usuwaj nieużywanych użytkowników (state: absent)

## Zobacz także

- [USER-MODULE.md](USER-MODULE.md) - Moduł dla pojedynczych użytkowników
- [SUDOERS-MODULE.md](SUDOERS-MODULE.md) - Konfiguracja uprawnień sudo
- [USER-SETUP-GUIDE.md](USER-SETUP-GUIDE.md) - Przewodnik konfiguracji użytkowników

## Wsparcie

W razie problemów:
1. Sprawdź logi Ansible
2. Użyj trybu verbose: `-v` lub `-vvv`
3. Testuj z `--check` przed zmianami
4. Sprawdź uprawnienia sudo
5. Zweryfikuj składnię YAML
