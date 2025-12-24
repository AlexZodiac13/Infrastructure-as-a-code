#!/usr/bin/env bash
set -euo pipefail

LOGDIR="../logs"
mkdir -p "$LOGDIR"

if [ -z "${YC_TOKEN:-}" ]; then
  echo "Error: YC_TOKEN is not set. Export YC_TOKEN='...' (use yc iam create-token) before running." >&2
  exit 2
fi

# Ensure plugin present
./download_plugin.sh

export ANSIBLE_CONFIG=./ansible.cfg

echo "Running ansible-inventory (writing to $LOGDIR/yacloud_plugin_inventory.yaml)"
ansible-inventory -i ./inventory --list -y > "$LOGDIR/yacloud_plugin_inventory.yaml" 2>&1 || true

echo "Running ansible ping to group wp_app (writing to $LOGDIR/yacloud_plugin_ping.txt)"
# Use local connection fallback if instances report 127.0.0.1; ansible may try ssh otherwise
ansible -i ./inventory -m ping wp_app > "$LOGDIR/yacloud_plugin_ping.txt" 2>&1 || true

echo "Logs written to:"
echo "  $LOGDIR/yacloud_plugin_inventory.yaml"
echo "  $LOGDIR/yacloud_plugin_ping.txt"

echo "Tip: Inspect the inventory YAML to ensure instances and IPs are present. If ping fails due to SSH, consider adding 'ansible_connection: local' to hostvars, or use proper SSH user/key in your inventory config."