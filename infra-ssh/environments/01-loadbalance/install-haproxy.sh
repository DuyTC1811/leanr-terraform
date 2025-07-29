#!/bin/bash
set -xe

MASTER_IPS="$1"

echo "[ SETUP AND SETTING HAPROXY ]"
curl https://haproxy.debian.net/haproxy-archive-keyring.gpg > /usr/share/keyrings/haproxy-archive-keyring.gpg
echo deb "[signed-by=/usr/share/keyrings/haproxy-archive-keyring.gpg]" http://haproxy.debian.net bookworm-backports-3.2 main > /etc/apt/sources.list.d/haproxy.list

echo "[ ENABLE HAPROXY TO AUTOMATICALLY START ON REBOOT ]"
sudo systemctl enable --now haproxy

echo "[ CONFIGURATION HAPROXY ]" 
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

echo "[ CHECK STATUS HAPROXY ]" 
sudo haproxy -c -f /etc/haproxy/haproxy.cfg
sudo systemctl restart haproxy
sudo systemctl status haproxy --no-pager

echo "[ ALLOWING HAPROXY PORTS IN FIREWALL ]"
sudo ufw allow 6443/tcp
sudo ufw allow 2379/tcp
sudo ufw allow 2380/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10251/tcp
sudo ufw allow 10252/tcp
sudo ufw allow 10255/tcp
sudo ufw reload