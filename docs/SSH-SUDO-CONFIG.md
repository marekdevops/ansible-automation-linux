# Konfiguracja SSH i Sudo dla Ansible

## Problem z Root
Domyślnie skrypty były skonfigurowane do logowania bezpośrednio jako root, co nie jest bezpieczne. Została zmieniona konfiguracja na standard: **zwykły użytkownik + sudo**.

## Aktualna konfiguracja

### ansible.cfg
```ini
[defaults]
# Nie ustawiamy remote_user globalnie - każdy host sam definiuje
private_key_file = ~/.ssh/id_rsa
ask_pass = False
ask_sudo_pass = False

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
```

### Inventory
Każdy host definiuje swojego użytkownika:
```yaml
hosts:
  server1:
    ansible_host: 192.168.1.10
    ansible_user: your_username    # Twój użytkownik (NIE root!)
    ansible_become: true           # Użyj sudo
```

## Konfiguracja na serwerach zdalnych

### 1. Utwórz użytkownika administratora
```bash
# Na każdym serwerze zdalnym
sudo adduser admin
sudo usermod -aG sudo admin
```

### 2. Konfiguracja sudo bez hasła (opcjonalnie)
```bash
# Dodaj do /etc/sudoers.d/admin
echo "admin ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/admin
sudo chmod 440 /etc/sudoers.d/admin
```

### 3. Skonfiguruj klucze SSH
```bash
# Na swoim komputerze (jeśli nie masz klucza)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Skopiuj klucz na serwer
ssh-copy-id admin@server_ip

# Test połączenia
ssh admin@server_ip
```

## Aktualizacja inventory

### 1. Podstawowa konfiguracja
```yaml
# inventory/hosts.yml
production:
  hosts:
    server1:
      ansible_host: 192.168.1.10
      ansible_user: admin          # Twój użytkownik
      ansible_become: true         # Użyj sudo
  vars:
    ansible_become_method: sudo
    ansible_become_user: root
```

### 2. Różni użytkownicy per środowisko
```yaml
# Produkcja - dedykowany admin
production:
  hosts:
    prod-server:
      ansible_host: 192.168.1.10
      ansible_user: admin
      
# Staging - vagrant/ubuntu
staging:
  hosts:
    stage-server:
      ansible_host: 192.168.2.10
      ansible_user: vagrant
      
# Development - twój user
development:
  hosts:
    dev-server:
      ansible_host: 192.168.3.10
      ansible_user: developer
```

## Testowanie konfiguracji

### 1. Test połączenia SSH
```bash
# Sprawdź czy możesz się połączyć bez hasła
ssh admin@server_ip

# Sprawdź sudo
ssh admin@server_ip "sudo whoami"  # Powinno zwrócić "root"
```

### 2. Test Ansible
```bash
# Test ping
ansible -i inventory/production.yml all -m ping

# Test sudo
ansible -i inventory/production.yml all -m shell -a "whoami"  # Powinno zwrócić "root"

# Test bez sudo
ansible -i inventory/production.yml all -m shell -a "whoami" --become=false  # Powinno zwrócić twojego usera
```

### 3. Test modułów
```bash
# Test z dry-run
./run-automation.sh -i inventory/production.yml user -e "user=testuser" -c

# Jeśli test OK, uruchom bez -c
./run-automation.sh -i inventory/production.yml user -e "user=testuser"
```

## Przykłady konfiguracji per serwer

### Serwer z kluczem SSH i portem 2222
```yaml
prod-web01:
  ansible_host: 192.168.1.10
  ansible_user: admin
  ansible_port: 2222
  ansible_ssh_private_key_file: ~/.ssh/prod_key
  ansible_become: true
```

### Serwer z hasłem (niezalecane)
```yaml
stage-server:
  ansible_host: 192.168.2.10
  ansible_user: ubuntu
  ansible_ssh_pass: "{{ vault_ssh_password }}"
  ansible_become: true
  ansible_become_pass: "{{ vault_sudo_password }}"
```

### Localhost
```yaml
localhost:
  ansible_connection: local
  ansible_user: "{{ ansible_env.USER }}"
  ansible_become: true
```

## Rozwiązywanie problemów

### Błąd: "Permission denied (publickey)"
```bash
# Sprawdź klucz SSH
ssh-add -l

# Skopiuj klucz ponownie
ssh-copy-id -i ~/.ssh/id_rsa admin@server_ip
```

### Błąd: "sudo: a password is required"
```bash
# Dodaj NOPASSWD do sudo
echo "admin ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/admin

# Lub użyj hasła w inventory
ansible_become_pass: "your_sudo_password"
```

### Błąd: "Authentication failure"
```bash
# Sprawdź użytkownika
ansible -i inventory/production.yml all -m shell -a "id" --become=false

# Sprawdź sudo
ansible -i inventory/production.yml all -m shell -a "sudo -n id"
```

## Bezpieczeństwo

### 1. Nigdy nie używaj root bezpośrednio
❌ **ZŁE:**
```yaml
ansible_user: root
```

✅ **DOBRE:**
```yaml
ansible_user: admin
ansible_become: true
```

### 2. Używaj kluczy SSH zamiast haseł
❌ **ZŁE:**
```yaml
ansible_ssh_pass: "password123"
```

✅ **DOBRE:**
```yaml
ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

### 3. Ograniczaj sudo do konkretnych komend
❌ **ZŁE:**
```bash
admin ALL=(ALL) NOPASSWD:ALL
```

✅ **DOBRE:**
```bash
admin ALL=(ALL) NOPASSWD:/usr/bin/systemctl, /usr/bin/apt
```

## Przykład kompletnej konfiguracji

### inventory/production.yml
```yaml
---
production:
  hosts:
    web01:
      ansible_host: 192.168.1.10
      ansible_user: admin
      ansible_port: 2222
      ansible_become: true
    web02:
      ansible_host: 192.168.1.11
      ansible_user: admin  
      ansible_port: 2222
      ansible_become: true
  vars:
    ansible_become_method: sudo
    ansible_become_user: root
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
```

### Test
```bash
# Test połączenia
ansible -i inventory/production.yml all -m ping

# Test sudo
ansible -i inventory/production.yml all -m shell -a "whoami"

# Uruchom moduł user
./run-automation.sh -i inventory/production.yml user -e "user=webmaster" -c
```