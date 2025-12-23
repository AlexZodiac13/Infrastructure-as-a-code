#!/usr/bin/env python3
"""Простой скрипт: terraform state -> ansible dynamic inventory

Поддерживает 2 варианта:
 - если в корне state есть outputs.instances.value = { host: {ip:.., labels:{group:..}} }
 - иначе пытается пройти по resources и найти атрибуты с IP и метками

Этот скрипт предназначен как пример и может потребовать адаптации под конкретный провайдер/манифест.
"""
import json
import os
import re

STATE_FILE = os.path.join(os.path.dirname(__file__), 'terraform.tfstate')
GROUP_LABEL = 'group'
TARGET_GROUP = 'wp_app'

ip_re = re.compile(r"\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b")


def load_state(path):
    if not os.path.exists(path):
        print(json.dumps({}))
        return None
    with open(path, 'r') as f:
        return json.load(f)


def from_outputs(state):
    outs = state.get('outputs', {})
    inst = outs.get('instances', {}).get('value')
    if not isinstance(inst, dict):
        return None

    hosts = {}
    for name, info in inst.items():
        labels = info.get('labels', {}) if isinstance(info, dict) else {}
        if labels.get(GROUP_LABEL) == TARGET_GROUP:
            ip = info.get('ip') or info.get('ansible_host')
            if ip:
                conn = 'local' if str(ip).startswith('127.') else 'ssh'
                hosts[name] = {'ansible_host': ip, 'ansible_connection': conn}
    return hosts

def scan_resources(state):
    hosts = {}
    resources = state.get('resources', [])
    for res in resources:
        instances = res.get('instances', [])
        for inst in instances:
            attrs = inst.get('attributes', {}) or {}
            # try to find labels
            labels = {}
            for k, v in attrs.items():
                if k.endswith('.labels') or k.endswith('.labels.%'):
                    # not ideal — provider-specific
                    pass
                if isinstance(v, dict) and v.get(GROUP_LABEL):
                    labels = v
            # generic search for group label
            for k, v in attrs.items():
                if isinstance(v, str) and v == TARGET_GROUP:
                    labels = {GROUP_LABEL: v}
            if labels.get(GROUP_LABEL) == TARGET_GROUP:
                # try to find an IP inside attributes
                found_ip = None
                for v in attrs.values():
                    if isinstance(v, str):
                        m = ip_re.search(v)
                        if m:
                            found_ip = m.group(0)
                            break
                    elif isinstance(v, list):
                        for item in v:
                            if isinstance(item, str):
                                m = ip_re.search(item)
                                if m:
                                    found_ip = m.group(0)
                                    break
                name = attrs.get('name') or attrs.get('id') or res.get('name')
                if name and found_ip:
                    conn = 'local' if str(found_ip).startswith('127.') else 'ssh'
                    hosts[name] = {'ansible_host': found_ip, 'ansible_connection': conn}
    return hosts


if __name__ == '__main__':
    state = load_state(STATE_FILE)
    if state is None:
        exit(0)

    hosts = from_outputs(state) or scan_resources(state) or {}

    inv = {TARGET_GROUP: {'hosts': list(hosts.keys())}, '_meta': {'hostvars': hosts}}
    print(json.dumps(inv))
