# tfs — пример Terraform для задачи

Этот каталог содержит пример манифестов и утилиту `tfs2inv.py`, которая преобразует `terraform.tfstate` в Ansible inventory.

Инструкции:
1. Отредактируйте `wp.auto.tfvars` и укажите идентификатор временной папки/облака, креды и т.д.
2. При наличии учётных данных выполните `terraform init` и `terraform apply` в отдельном каталоге облака.
3. Убедитесь, что ресурсы имеют метку `labels = { group = "wp_app" }` (см. `main.tf`).
4. После применения Terraform скрипт `tfs2inv.py` прочитает `terraform.tfstate` в текущем каталоге и выведет inventory для Ansible.

Примечание: В каталоге уже есть mock `terraform.tfstate` для локального теста.
