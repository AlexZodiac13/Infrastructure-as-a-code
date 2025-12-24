#!/usr/bin/env python3
"""
Простой конвертер terraform.tfstate -> Ansible dynamic inventory (JSON).
Ищет ресурсы с "yandex_compute_instance" и метку group="wp_app".
"""
import json
import os
import sys

STATE_PATH = os.environ.get('TF_STATE', 'terraform.tfstate')

try:
    with open(STATE_PATH) as f:
        state = json.load(f)
except Exception as e:
    print(json.dumps({}))
    sys.exit(0)

hosts = []
hostvars = {}

for module in state.get('resources', []):
    # Terraform <= 0.11 format may differ; also consider top-level resources
    if module.get('type') == 'yandex_compute_instance':
        for inst in module.get('instances', []):
            attrs = inst.get('attributes', {})
            labels = attrs.get('labels') or {}
            label_group = attrs.get('labels.group') or labels.get('group')
            if label_group != 'wp_app':
                continue
            name = attrs.get('name') or attrs.get('id') or attrs.get('network_interface.0.nat_ip') or attrs.get('network_interface.0.ip_address') or attrs.get('hostname')
            # try multiple attribute candidates for IP
            ip = None
            # common modern shape: network_interface.0.nat_ip or network_interface.0.address
            for k in ('network_interface.0.nat_ip', 'network_interface.0.ip_address', 'network_interface.0.address'):
                if k in attrs:
                    ip = attrs[k]
                    break
            # fallback: try nested 'network_interface' list
            if not ip and 'network_interface' in attrs:
                ni = attrs['network_interface']
                if isinstance(ni, list) and ni:
                    ip = ni[0].get('nat_ip') or ni[0].get('ip_address') or ni[0].get('address')
            if not name:
                name = attrs.get('platform_id') or attrs.get('id')
            if not ip:
                ip = attrs.get('metadata', {}).get('private_ip') or '127.0.0.1'
            hosts.append(name)
            conn = 'local' if ip in ('127.0.0.1', 'localhost') else 'ssh'
            hostvars[name] = {
                'ansible_host': ip,
                'ansible_connection': conn,
                'ansible_user': 'ubuntu',
                'ansible_private_key_file': '/home/zodiac/.ssh/otus',
                'ansible_python_interpreter': '/usr/bin/python3.8'
            }

inventory = {"_meta": {"hostvars": hostvars}, "wp_app": hosts}
print(json.dumps(inventory))
