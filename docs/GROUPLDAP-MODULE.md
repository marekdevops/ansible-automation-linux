# Moduł GROUPLDAP - Dokumentacja

## Opis
Moduł `groupldap` służy do zezwalania grupom AD/LDAP na logowanie do serwerów Linux. Wykorzystuje komendę `realm permit -g` do konfiguracji dostępu.

## Podstawowe użycie

### Składnia
```bash
./run-automation.sh groupldap -e "group=NAZWA_GRUPY"
```

### Wymagane parametry
- `group` - nazwa grupy AD/LDAP (np. `Domain_Admins`, `IT_Support`)

## Wymagania
- Pakiet `realmd` musi być zainstalowany na serwerze
- Serwer musi być przyłączony do domeny AD (przez `realm join`)

## Przykłady użycia

### 1. Zezwolenie grupie AD na logowanie
```bash
# Zezwól grupie Domain_Admins na wszystkich hostach
./run-automation.sh groupldap -e "group=Domain_Admins"

# Zezwól grupie IT_Support
./run-automation.sh groupldap -e "group=IT_Support"
```

### 2. Ograniczenie do konkretnego hosta
```bash
# Zezwól grupie tylko na test-server
./run-automation.sh groupldap -e "group=DevOps_Team" -l test-server
```

### 3. Dry-run (sprawdzenie)
```bash
# Sprawdź co zostanie wykonane bez zmian
./run-automation.sh groupldap -e "group=Domain_Admins" -c
```

### 4. Wiele grup
```bash
# Uruchom dla każdej grupy osobno
./run-automation.sh groupldap -e "group=Domain_Admins"
./run-automation.sh groupldap -e "group=IT_Support"
./run-automation.sh groupldap -e "group=Developers"
```

## Jak to działa

Moduł wykonuje następujące kroki:
1. Sprawdza czy `realm` jest zainstalowany
2. Wyświetla aktualny status `realm list`
3. Wykonuje `realm permit -g NAZWA_GRUPY`
4. Wyświetla podsumowanie

## Zarządzanie dostępem

### Sprawdzenie aktualnych uprawnień
```bash
# Wyświetl dozwolone grupy
realm list

# Szczegóły domeny
realm list --all
```

### Cofnięcie dostępu
```bash
# Cofnij dostęp dla grupy
sudo realm deny -g NAZWA_GRUPY

# Cofnij dostęp dla wszystkich
sudo realm deny --all
```

### Zezwolenie wszystkim
```bash
# Zezwól wszystkim użytkownikom domeny
sudo realm permit --all
```

## Rozwiązywanie problemów

### Częste błędy

**Błąd**: "realm: command not found"
- **Przyczyna**: Pakiet realmd nie jest zainstalowany
- **Rozwiązanie**:
  - Debian/Ubuntu: `apt install realmd`
  - RHEL/CentOS: `yum install realmd`

**Błąd**: "No such realm"
- **Przyczyna**: Serwer nie jest przyłączony do domeny
- **Rozwiązanie**: Przyłącz serwer do domeny przez `realm join`

**Błąd**: "Permission denied"
- **Przyczyna**: Brak uprawnień root
- **Rozwiązanie**: Ansible używa `become: true`, sprawdź konfigurację sudo

### Diagnostyka
```bash
# Sprawdź status realm
realm list

# Sprawdź czy serwer jest w domenie
realm discover DOMENA.LOCAL

# Sprawdź SSSD
systemctl status sssd
```

## Przykład pełnego workflow

```bash
# 1. Sprawdź aktualny status (dry-run)
./run-automation.sh groupldap -e "group=IT_Support" -l test-server -c

# 2. Zezwól grupie na logowanie
./run-automation.sh groupldap -e "group=IT_Support" -l test-server

# 3. Dodaj uprawnienia sudo dla tej grupy
./run-automation.sh sudoers -e "groupldap=IT_Support target_user=appuser" -l test-server

# 4. Przetestuj logowanie
ssh uzytkownik@test-server
```

## Powiązane moduły
- [SUDOERS-MODULE.md](SUDOERS-MODULE.md) - konfiguracja uprawnień sudo dla grup AD
- [USERSLDAP-MODULE.md](USERSLDAP-MODULE.md) - nadpisywanie atrybutów użytkowników LDAP
