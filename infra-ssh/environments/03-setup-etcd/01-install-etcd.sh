#!/bin/bash

set -xe
ROLE=$1

echo "[ INSTALL ETCD ]"
ETCD_VER=v3.6.4

GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GOOGLE_URL}

echo "[ CLEAN UP AND PREPARE TEMPORARY FOLDER ]"
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test

echo "[ DOWNLOAD AND UNZIP ETCD ]"
curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1 --no-same-owner
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
sudo mkdir -p /var/lib/etcd/

echo "[ EXECUTABLE CHECK VERSION ]"
/tmp/etcd-download-test/etcd --version
/tmp/etcd-download-test/etcdctl version
/tmp/etcd-download-test/etcdutl version
sudo cp /tmp/etcd-download-test/etcdctl /usr/local/bin/
sudo cp /tmp/etcd-download-test/etcd /usr/local/bin/
sudo cp /tmp/etcd-download-test/etcdutl /usr/local/bin/

etcdctl version
etcd --version
etcdutl version

echo "[ OPEN PORTS 2379 AND 2380 ]"
sudo ufw allow 2379:2380/tcp

sudo hostnamectl set-hostname "$ROLE"
echo "ETCD setup complete for role: $ROLE"
echo -e "\e[34m[DONE] ETCD INSTALL \e[0m"
