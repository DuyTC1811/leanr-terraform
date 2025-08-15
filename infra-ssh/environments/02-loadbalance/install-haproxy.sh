#!/bin/bash
set -xeuo pipefail

MASTER_IPS="$1"

echo "[INFO] Installing HAProxy..."
curl https://haproxy.debian.net/haproxy-archive-keyring.gpg > /usr/share/keyrings/haproxy-archive-keyring.gpg
echo deb "[signed-by=/usr/share/keyrings/haproxy-archive-keyring.gpg]" http://haproxy.debian.net bookworm-backports-3.2 main > /etc/apt/sources.list.d/haproxy.list

sudo apt-get update -y
sudo apt-get install -y haproxy

echo "[INFO] Enabling and starting HAProxy..."
sudo systemctl enable --now haproxy

echo "[INFO] Generating HAProxy config..."
cat <<'EOF' | sudo tee /etc/haproxy/haproxy.cfg >/dev/null
global
    # local2.*  /var/log/haproxy.log
    log         127.0.0.1 local2

    chroot	    /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group	    haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    tcp
    log                     global
    option                  tcplog
    retries                 3
    timeout connect         10s
    timeout client          1m
    timeout server          1m

frontend front
    bind *:80
    mode http
    acl is_argocd path_beg /argocd
    acl is_nginx  path_beg /nginx

    use_backend back-argocd if is_argocd
    use_backend back-nginx  if is_nginx

backend back-argocd
    mode http
    http-request set-header Host www.argocd.com
    server gw-server 20.0.20.101:80

backend back-nginx
    mode http
    http-request set-header Host www.nginx.com
    server gw-server 20.0.20.101:80

#---------------------------------------------------------------------
# k8s-api frontend which proxys to the backends
#---------------------------------------------------------------------
frontend k8s-frontend
    bind *:6443
    default_backend             k8s-backend

#---------------------------------------------------------------------
# Backend cho Kubernetes API Server
#---------------------------------------------------------------------
backend k8s-backend
    option tcp-check
    balance roundrobin
EOF

i=1
for ip in $MASTER_IPS; do
  echo "    server master-$(printf '%02d' $i) $ip:6443 check" >> /etc/haproxy/haproxy.cfg
  ((i++))
done

echo "[INFO] Checking HAProxy config..."
sudo haproxy -c -f /etc/haproxy/haproxy.cfg

echo "[INFO] Restarting HAProxy..."
sudo systemctl restart haproxy
sudo systemctl status haproxy --no-pager

echo "[INFO] Opening necessary ports with UFW..."
sudo ufw allow 6443/tcp
sudo ufw allow 2379/tcp
sudo ufw allow 2380/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10251/tcp
sudo ufw allow 10252/tcp
sudo ufw allow 10255/tcp
sudo ufw allow 4240/tcp
sudo ufw allow 179/tcp
sudo ufw reload
echo -e "\e[34m[DONE] HAProxy setup complete!\e[0m"
