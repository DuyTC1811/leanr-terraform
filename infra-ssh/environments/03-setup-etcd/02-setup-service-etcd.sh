#!/bin/bash

set -xe

cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
After=network.target

[Service]
ExecStart=/usr/local/bin/etcd \\
  --name etcd-01 \\
  --initial-advertise-peer-urls https://192.168.1.51:2380 \\
  --listen-peer-urls https://192.168.1.51:2380 \\
  --listen-client-urls https://192.168.1.51:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://192.168.1.51:2379 \\
  --initial-cluster etcd-01=https://192.168.1.51:2380 \\
  --initial-cluster-state new \\
  --initial-cluster-token etcd-cluster-1 \\
  --data-dir=/var/lib/etcd/data \\
  --wal-dir=/var/lib/etcd/wal \\
  --snapshot-count 10000 \\
  --log-outputs=/var/lib/etcd/etcd.log \\
  --client-cert-auth \\
  --trusted-ca-file=/var/lib/etcd/ca.pem \\
  --cert-file=/var/lib/etcd/etcd.pem \\
  --key-file=/var/lib/etcd/etcd-key.pem \\
  --peer-auto-tls
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "[ RELOAD AND START ETCD SERVICE ]"
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd

echo -e "\e[34m[DONE] CONFIG ETCD \e[0m"

# echo "[ TEST ETCD ]"
# etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/var/lib/etcd/ca.pem --cert=/var/lib/etcd/etcd.pem --key=/var/lib/etcd/etcd-key.pem del foo || true
# etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/var/lib/etcd/ca.pem --cert=/var/lib/etcd/etcd.pem --key=/var/lib/etcd/etcd-key.pem put foo "Hello ETCD"
# etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/var/lib/etcd/ca.pem --cert=/var/lib/etcd/etcd.pem --key=/var/lib/etcd/etcd-key.pem get foo

