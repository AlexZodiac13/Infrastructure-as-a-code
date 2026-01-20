# Infrastructure as Code: Terraform + Ansible

Проект развертывания инфраструктуры в Yandex.Cloud с использованием Terraform и настройки приложения Wordpress с помощью Ansible.

## Структура репозитория

* `terraform/` — Конфигурация инфраструктуры (VMs, DB, Network, Load Balancer).
* `ansible/` — Роли и плейбуки для настройки серверов.
* `.gitlab-ci.yml` — Пайплайн CI/CD для автоматического деплоя.

## CI/CD Pipeline

Пайплайн настроен для полной автоматизации процесса деплоя:

1. **Deploy Infrastructure (`deploy_infra`)**:
   * Поднимает инфраструктуру через Terraform.
   * **Автоматически генерирует файлы конфигурации Ansible**:
     * `ansible/environments/prod/inventory` — заполняется публичными IP адресами созданных ВМ.
     * `ansible/environments/prod/group_vars/wp_app` — заполняется параметрами подключения к БД (хост, имя, пользователь, пароль).
   * Эти файлы передаются следующему этапу как артефакты.

2. **Install Application (`deploy_app`)**:
   * Использует сгенерированные на предыдущем шаге инвентарь и переменные.
   * Запускает Ansible Playbook для установки и настройки Wordpress.

## Запуск вручную 

### 1. Terraform

```bash
cd terraform

# Инициализация
terraform init

# Просмотр плана
terraform plan

# Применение
terraform apply -auto-approve
```

После успешного применения обратите внимание на Outputs:
* `load_balancer_public_ip`
* `vm_linux_public_ip_address`
* `database_host_fqdn`

### 2. Ansible

Если вы запускаете Ansible локально после Terraform, вам нужно актуализировать инвентарь и переменные.

1. Обновите `ansible/environments/prod/inventory` IP-адресами из вывода Terraform.
2. Обновите `ansible/environments/prod/group_vars/wp_app` параметрами базы данных.
3. Убедитесь, что SSL сертификат для БД присутствует (если требуется):
   ```bash
   wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" -O ansible/roles/wordpress/files/root.crt
   ```
   *(Путь может отличаться в зависимости от конфигурации роли)*

4. Запустите playbook:
   ```bash
   cd ansible
   ansible-playbook playbooks/install.yml
   ```

### 3. Удаление ресурсов

```bash
cd terraform
terraform destroy -auto-approve
```