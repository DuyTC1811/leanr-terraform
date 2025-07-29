#!/bin/bash
set -e  # Dừng script nếu có lỗi
set -u  # Dừng nếu sử dụng biến chưa được khai báo

# Create a directory for storing certificates
echo ">>> CREATING CERTIFICATE DIRECTORY..."
CERT_DIR="openssl"
mkdir -p ${CERT_DIR} && cd ${CERT_DIR}

# 1. Create CA key and certificate
echo ">>> CREATING CA KEY AND CERTIFICATE..."
openssl genrsa -out ca-key.pem 2048
openssl req -new -key ca-key.pem -out ca-csr.pem -subj "/C=VN/ST=Metri/L=Hanoi/O=example/CN=ca"
openssl x509 -req -in ca-csr.pem -out ca.pem -days 3650 -signkey ca-key.pem -sha256

# 2. create etcd key and CSR (Certificate Signing Request)
echo ">>> CREATING ETCD KEY AND CSR..."
openssl genrsa -out etcd-key.pem 2048
openssl req -new -key etcd-key.pem -out etcd-csr.pem -subj "/C=VN/ST=Metri/L=Hanoi/O=example/CN=etcd"

# 3. create SAN (Subject Alternative Name) configuration
echo ">>> CREATING SAN CONFIGURATION..."
cat <<EOF > extfile.cnf
subjectAltName = DNS:localhost,IP:192.168.1.50,IP:127.0.0.1
EOF

# 4. Sign the etcd CSR with the CA certificate
echo ">>> SIGNING ETCD CERTIFICATE WITH CA..."
openssl x509 -req -in etcd-csr.pem -CA ca.pem -CAkey ca-key.pem -CAcreateserial -days 3650 -out etcd.pem -sha256 -extfile extfile.cnf

# 5. show the generated files
echo ">>> DISPLAYING GENERATED CERTIFICATES..."
echo ">>> Certificates have been successfully created in the '${CERT_DIR}' directory."
ls -l

# - C=VN:       Quốc gia (Vietnam).
# - ST=Metri:   Bang/Tỉnh.
# - L=Hanoi:    Thành phố.
# - O=example:  Tổ chức.
# - CN=ca:      Tên Thông thường (Common Name).
# - days 3650:  Thời hạn (~10 năm).