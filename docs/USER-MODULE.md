# Moduł USER - Dokumentacja

## Opis
Moduł `user` służy do tworzenia i zarządzania użytkownikami systemu Linux z elastyczną konfiguracją katalogu domowego.

## Podstawowe użycie

### Składnia
```bash
./run-automation.sh user -e "user=NAZWA [opcje]"
```

### Wymagane parametry
- `user` - nazwa użytkownika do utworzenia

### Opcjonalne parametry
- `home` - katalog domowy (domyślnie: `default`)
- `shell` - shell użytkownika (domyślnie: `/bin/bash`)
- `groups` - dodatkowe grupy (oddzielone przecinkami)
- `password` - hasło użytkownika (będzie zahashowane)
- `ssh_key` - klucz publiczny SSH
- `sudo` - dostęp sudo (`true`/`false`, domyślnie: `false`)

## Przykłady użycia

### 1. Podstawowy użytkownik
```bash
# Tworzy użytkownika 'jan' z katalogiem /home/jan
./run-automation.sh user -e "user=jan"
```

### 2. Użytkownik z domyślnym katalogiem
```bash
# Równoznaczne z powyższym
./run-automation.sh user -e "user=jan home=default"
```

### 3. Użytkownik z niestandardowym katalogiem (pełna ścieżka)
```bash
# Tworzy użytkownika 'tomcat' z katalogiem /opt/tomcat
./run-automation.sh user -e "user=tomcat home=/opt/tomcat"
```

### 4. Użytkownik z niestandardowym katalogiem (nazwa)
```bash
# Tworzy użytkownika 'www' z katalogiem /home/webuser
./run-automation.sh user -e "user=www home=webuser"
```

### 5. Użytkownik z dostępem sudo
```bash
# Tworzy użytkownika z uprawnieniami administratora
./run-automation.sh user -e "user=admin home=default sudo=true"
```

### 6. Użytkownik z hasłem
```bash
# Tworzy użytkownika z hasłem
./run-automation.sh user -e "user=pracownik home=default password=MojeHaslo123"
```

### 7. Użytkownik z kluczem SSH
```bash
# Tworzy użytkownika z kluczem SSH
./run-automation.sh user -e "user=developer home=default ssh_key='ssh-rsa AAAAB3Nza...'"
```

### 8. Użytkownik z dodatkowymi grupami
```bash
# Tworzy użytkownika w dodatkowych grupach
./run-automation.sh user -e "user=webmaster home=default groups=www-data,developers"
```

### 9. Kompletny przykład
```bash
# Tworzy użytkownika z pełną konfiguracją
./run-automation.sh user -e "
  user=admin 
  home=/home/administrator
  sudo=true
  groups=sudo,adm
  shell=/bin/zsh
  password=SecurePass123
"
```

## Logika katalogów domowych

| Parametr `home` | Wynikowy katalog | Opis |
|----------------|------------------|------|
| `default` | `/home/UŻYTKOWNIK` | Standardowy katalog |
| `/pełna/ścieżka` | `/pełna/ścieżka` | Bezpośrednia ścieżka |
| `nazwa` | `/home/nazwa` | Katalog w /home |

### Przykłady:
- `home=default` → `/home/jan` (dla user=jan)
- `home=/opt/tomcat` → `/opt/tomcat`
- `home=webuser` → `/home/webuser`
- `home=/var/www` → `/var/www`

## Co robi moduł

1. **Sprawdza** czy użytkownik już istnieje
2. **Tworzy** katalogi nadrzędne (jeśli potrzebne)
3. **Tworzy/aktualizuje** użytkownika
4. **Ustawia** właściciela katalogu domowego
5. **Dodaje** do grup (jeśli podane)
6. **Konfiguruje** sudo (jeśli włączone)
7. **Dodaje** klucz SSH (jeśli podany)
8. **Wyświetla** podsumowanie

## Sprawdzenie przed uruchomieniem

### Dry-run
```bash
# Sprawdzenie bez zmian
./run-automation.sh user -e "user=test home=/opt/test" -c
```

### Verbose
```bash
# Szczegółowy output
./run-automation.sh user -e "user=admin" -v
```

## Wskazówki bezpieczeństwa

1. **Hasła** - używaj silnych haseł lub kluczy SSH
2. **Sudo** - przyznawaj ostrożnie uprawnienia sudo
3. **Katalogi** - sprawdź uprawnienia do katalogów nadrzędnych
4. **Klucze SSH** - używaj bezpiecznych kluczy

## Rozwiązywanie problemów

### Częste błędy:

**Błąd**: "Musisz podać nazwę użytkownika!"
- **Rozwiązanie**: Dodaj parametr `user=nazwa`

**Błąd**: Brak uprawnień do utworzenia katalogu
- **Rozwiązanie**: Sprawdź czy Ansible ma uprawnienia sudo

**Błąd**: Katalog już istnieje ale należy do innego użytkownika
- **Rozwiązanie**: Moduł automatycznie zmieni właściciela

### Debug:
```bash
# Sprawdź użytkownika
id NAZWA_UŻYTKOWNIKA

# Sprawdź katalog domowy
ls -la /ścieżka/do/katalogu

# Sprawdź grupy
groups NAZWA_UŻYTKOWNIKA
```