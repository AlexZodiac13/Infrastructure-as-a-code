Локальная проверка (terraform)

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