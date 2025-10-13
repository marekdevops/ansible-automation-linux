# Przewodnik Konfiguracji Użytkownika na Serwerze Zdalnym

## 1. Tworzenie użytkownika na serwerze (jako root lub sudo)

```bash
# Na serwerze zdalnym (jako root lub przez sudo):

# Utwórz użytkownika
sudo useradd -m -s /bin/bash twoj_user

# Ustaw hasło (opcjonalnie)
sudo passwd twoj_user

# Dodaj do grupy sudo
sudo usermod -aG sudo twoj_user

# Sprawdź grupy
groups twoj_user
```

## 2. Konfiguracja sudo bez hasła (ZALECANE)

```bash
# Na serwerze zdalnym:
echo 'twoj_user ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/twoj_user
```

## 3. Konfiguracja klucza SSH

### Na lokalnej maszynie (gdzie uruchamiasz Ansible):

```bash
# Generuj klucz SSH (jeśli nie masz)
ssh-keygen -t rsa -b 4096 -C "twoj@email.com"

# Skopiuj klucz na serwer
ssh-copy-id twoj_user@adres_serwera

# Alternatywnie ręcznie:
cat ~/.ssh/id_rsa.pub
```

### Na serwerze zdalnym:

```bash
# Jako twoj_user
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "TWÓJ_KLUCZ_PUBLICZNY" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

## 4. Test połączenia SSH

```bash
# Test z lokalnej maszyny
ssh twoj_user@adres_serwera

# Test sudo
ssh twoj_user@adres_serwera 'sudo whoami'
```

## 5. Konfiguracja inventory

W pliku `inventory/hosts.yml`:

```yaml
all:
  children:
    servers:
      hosts:
        server1:
          ansible_host: 192.168.1.100
          ansible_user: twoj_user
          ansible_become: true
          ansible_become_method: sudo
          # ansible_become_pass: haslo  # tylko jeśli nie ma NOPASSWD
```

## 6. Test Ansible

```bash
# Test skryptem
./test-ssh-sudo.sh inventory/hosts.yml

# Lub ręcznie:
ansible -i inventory/hosts.yml all -m ping
ansible -i inventory/hosts.yml all -m shell -a "whoami"
```

## Rozwiązywanie problemów

### Problem: "sudo: a password is required"
```bash
# Na serwerze dodaj NOPASSWD:
echo 'twoj_user ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/twoj_user
```

### Problem: "Permission denied (publickey)"
```bash
# Sprawdź klucz SSH:
ssh-copy-id -i ~/.ssh/id_rsa.pub twoj_user@serwer

# Sprawdź SSH config
ssh -v twoj_user@serwer
```

### Problem: "User twoj_user is not in the sudoers file"
```bash
# Na serwerze jako root:
usermod -aG sudo twoj_user
```

### Problem: SSH działa, ale sudo nie
```bash
# Sprawdź sudo config
sudo visudo
# lub sprawdź plik
sudo cat /etc/sudoers.d/twoj_user
```