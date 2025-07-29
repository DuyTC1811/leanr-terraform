#!/bin/bash
set -xe

ENTRIES_STRING="$1"

IFS=';' read -ra entries <<< "$ENTRIES_STRING"
for line in "${entries[@]}"; do
  ip=$(echo "$line" | awk '{print $1}')
  hostname=$(echo "$line" | awk '{print $2}')
  
  # Nếu chưa tồn tại thì thêm vào /etc/hosts
  if ! grep -q "$ip" /etc/hosts; then
    echo "$ip    $hostname" >> /etc/hosts
    echo "[+] Added $ip -> $hostname"
  else
    echo "[=] Skipped $ip (already exists)"
  fi
done
