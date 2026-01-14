Terraform

1) Перейдите в корень проекта
   cd d:\mygit\Infrastructure-as-a-code

2) Инициализируйте Terraform:
   terraform init

3) Проверьте план:
   terraform plan 

4) Примените:
   terraform apply -auto-approve 

5) Посмотрите outputs:
   terraform output load_balancer_public_ip
   terraform output vm_linux_public_ip_address
   terraform output database_host_fqdn

6) Проверка SSH:
   ssh -i /path/to/private/key <user>@<ip> 
   например:
   ssh -i /home/zodiac/.ssh/otus zodiac@84.201.159.187

7) Проверка MySQL (если DB имеет публичный IP и разрешает подключение):
   mysql -h <db-host> -u user -p'password' db
   или:
   echo "SELECT 1" | mysql -h <db-host> -u user -p'password' db

8) Удаление:
   terraform destroy -auto-approve

Тестирование через Terratest

1) Установите Go (https://golang.org/doc/install) и убедитесь, что $GOPATH/bin в PATH.

2) Перейдите в каталог тестов:
   cd d:\mygit\Infrastructure-as-a-code\test

3) Подтяните зависимости:
   go mod tidy
   или
   go mod vendor

4) Запуск тестов (пример):
   go test -v ./ -timeout 30m -folder 'ID_CATALOG_STAGE' -ssh-key-pass '/home/zodiac/.ssh/otus'

Параметры:
- -folder — ID каталога YC, в котором будут создаваться ресурсы (stage).
- -ssh-key-pass — путь к приватному ключу, используемому для SSH.
- Флаги окружения SKIP_*:
  - SKIP_setup=true — пропустить создание инфраструктуры
  - SKIP_validate=true — пропустить валидацию
  - SKIP_teardown=true — пропустить удаление инфраструктуры
 
Ansible deployment

1) Скопируйте IP-адреса из terraform outputs в inventory (`environments/prod/inventory`) или замените переменные:
   app ansible_host=<VM1_PUBLIC_IP>
   app2 ansible_host=<VM2_PUBLIC_IP>

5) Установите FQDN базы в `environments/prod/group_vars/wp_app` (wordpress_db_host) и остальные переменные.

6) wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" -O ./files/root.crt

7) Run the playbook:
   cd ansible
   
   Путь к ansible.cfg, на чистом linux указывать не надо, но мне приходится из-за wsl. Можно перенести в линуксовые директории, тогда сработает
   export ANSIBLE_CONFIG=/mnt/d/mygit/Infrastructure-as-a-code/ansible/ansible.cfg

   ansible-playbook playbooks/install.yml

---

## (Task 5) 

- **Проверил** простой динамический inventory `hello.py` — `--host`, `--list`, `ansible-inventory` и `ansible -m ping` работают.
- **Terraform:** добавил метку `group = "wp_app"` и **cloud-init**, чтобы создать пользователя `ubuntu` с вашим публичным SSH-ключом.
- **tfs/tfs2inv.py:** конвертер `terraform.tfstate` → Ansible inventory; hostvars теперь содержат `ansible_user: ubuntu`, `ansible_private_key_file` и `ansible_python_interpreter`.
- **Плагин yacloud_compute:** настроен в `plugin/`, скачан и протестирован — `ansible-inventory --list` показывает VMs, `ansible -m ping wp_app` — оба хоста ответили.
- **Логи:** сохранены в `logs/` (см. `yacloud_plugin_inventory_run4.yaml`, `yacloud_plugin_inventory_after_cloudinit.yaml`, `yacloud_plugin_ping_final.txt`).
