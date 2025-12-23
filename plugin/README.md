# plugin — пример настройки плагина yacloud_compute

Инструкции:
1. Скачайте реальную реализацию `yacloud_compute.py` из репозитория (например, https://github.com/rodion-goritskov/yacloud_compute).
2. Поместите её в `plugin/plugins/inventory/yacloud_compute.py`.
3. Создайте `plugin/inventory/yacloud_compute.yml` с вашим токеном или настройками IAM.
4. Запустите `ANSIBLE_CONFIG=plugin/ansible.cfg ansible-inventory --list` чтобы проверить.

ВНИМАНИЕ: не публикуйте OAuth-токен в публичных репозиториях!
