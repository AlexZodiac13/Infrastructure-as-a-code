#!/usr/bin/env python3
"""
Простейшее динамическое inventory для Ansible.
Поддерживает --list и --host <hostname>.
"""
import sys
import json

DATA = {
    "_meta": {
        "hostvars": {
            "hello": {"ansible_host": "127.0.0.1", "ansible_connection": "local"},
            "world": {"ansible_host": "127.0.0.1", "ansible_connection": "local"}
        }
    },
    "hello": ["hello"],
    "world": ["world"],
    "all": ["hello", "world"]
}


def main():
    if len(sys.argv) == 1:
        print(json.dumps(DATA))
        return

    if sys.argv[1] in ("--list", "-list"):
        print(json.dumps(DATA))
        return

    if sys.argv[1] == "--host":
        if len(sys.argv) < 3:
            print(json.dumps({}))
            return
        host = sys.argv[2]
        hostvars = DATA.get("_meta", {}).get("hostvars", {})
        print(json.dumps(hostvars.get(host, {})))
        return

    # fallback
    print(json.dumps({}))

if __name__ == '__main__':
    main()
