# Краткая проверка динамических inventory

- `hello/hello.py` — простой динамический inventory (поддерживает `--list` и `--host`).
- `tfs/tfs2inv.py` — пример преобразования `terraform.tfstate` в inventory (группа `wp_app`).
- `plugin/` — шаблон настройки `yacloud_compute` (требует реального плагина и токена).

Проверка 

1) Скрипт:
   ./hello/hello.py --host hello
   ./hello/hello.py --host world
   ./hello/hello.py --list

2) Ansible + script:
   ansible-inventory -i hello/hello.py --list
   ansible -i hello/hello.py -m ping all
   (Ожидается: `hello` и `world` — SUCCESS, ping: pong)

