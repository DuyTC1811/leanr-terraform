#!/bin/bash
set -e  # Dừng script nếu có lỗi
set -u  # Dừng nếu dùng biến chưa được khai báo

# Đường dẫn đến thư mục chứa certificate (relative path từ nơi gọi)
CERT_BASE_DIR="${1:-../../common-key}"  # Mặc định là ../../common-key nếu không truyền
CERT_DIR="${CERT_BASE_DIR}/openssl"

echo ">>> CREATING CERTIFICATE DIRECTORY: ${CERT_DIR} ..."
mkdir -p "${CERT_DIR}"

# Di chuyển vào thư mục đó để thao tác
cd "${CERT_DIR}"

# 1. Create CA key and certificate
echo ">>> CREATING CA KEY AND CERTIFICATE..."
openssl genrsa -out ca-key.pem 2048
openssl req -new -key ca-key.pem -out ca-csr.pem -subj "/C=VN/ST=Metri/L=Hanoi/O=example/CN=ca"
openssl x509 -req -in ca-csr.pem -out ca.pem -days 3650 -signkey ca-key.pem -sha256

# 2. Create etcd key and CSR
echo ">>> CREATING ETCD KEY AND CSR..."
openssl genrsa -out etcd-key.pem 2048
openssl req -new -key etcd-key.pem -out etcd-csr.pem -subj "/C=VN/ST=Metri/L=Hanoi/O=example/CN=etcd"

# 3. Create SAN config
echo ">>> CREATING SAN CONFIGURATION..."
cat <<EOF > extfile.cnf
subjectAltName = DNS:localhost,IP:192.168.1.51,IP:127.0.0.1
EOF

# 4. Sign etcd CSR with CA cert
echo ">>> SIGNING ETCD CERTIFICATE WITH CA..."
openssl x509 -req -in etcd-csr.pem -CA ca.pem -CAkey ca-key.pem -CAcreateserial -days 3650 -out etcd.pem -sha256 -extfile extfile.cnf

# 5. Show generated files
echo ">>> DISPLAYING GENERATED CERTIFICATES..."
ls -l

echo -e ">>>\e[34m Certificates have been successfully created in '${CERT_DIR}'\e[0m"
