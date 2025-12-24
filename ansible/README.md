Ansible role and playbook for WordPress

Usage:
1. After Terraform apply, get VM public IPs and DB FQDN:
   terraform output -raw vm_linux_public_ip_address
   terraform output -raw vm_linux_2_public_ip_address
   terraform output -raw database_host_fqdn | jq -r '.[0]'

2. Edit inventory at `environments/prod/inventory` with those IPs (replace placeholders):
   app ansible_host=<VM1_IP>
   app2 ansible_host=<VM2_IP>

3. Edit `environments/prod/group_vars/wp_app` and set `wordpress_db_host` to DB FQDN.

4. Fetch and install Yandex Cloud CA certificate into the role (recommended):
   - Linux/macOS:
     cd ansible
     ./scripts/fetch_ca.sh

   - Windows (PowerShell):
     cd ansible
     .\scripts\fetch_ca.ps1

   The scripts will save the CA to `roles/wordpress/files/root.crt`.

5. Run playbook:
   cd ansible
   ansible-playbook playbooks/install.yml

6. Visit Load Balancer IP (from terraform outputs) in browser.
