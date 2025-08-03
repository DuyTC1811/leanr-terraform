#!/bin/bash
set -e

### === THAM SỐ CẦN TRUYỀN === ###
# $1  - TOKEN (khóa token, ví dụ: abcdef.0123456789abcdef)
# $2  - ADVERTISE_ADDRESS (địa chỉ IP của node, ví dụ: 192.168.1.50)
# $3  - HOSTNAME (ví dụ: master)
# $4  - CONTROL_PLANE_ENDPOINT (ví dụ: 192.168.1.10)
# $5  - CERT_SANS (cách nhau bằng dấu phẩy, ví dụ: 192.168.1.10)
# $6  - ETCD_ENDPOINTS (cách nhau bằng dấu phẩy, ví dụ: 192.168.1.11,192.168.1.12)
##################################

TOKEN="$1"
ADVERTISE_ADDRESS="$2"
HOSTNAME="$3"
CONTROL_PLANE_ENDPOINT="$4"
CERT_SANS=(${5//,/ })
ETCD_ENDPOINTS=(${6//,/ })
CERTIFICATE_KEY=$(kubeadm certs certificate-key)

echo "[📦] Đang tạo kubeadm-config.yaml..."

cat <<EOF | sudo tee kubeadm-config.yaml > /dev/null
---
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration
bootstrapTokens:
  - token: "$TOKEN"
    description: "kubeadm bootstrap token"
    ttl: "24h"
    usages:
      - authentication
      - signing
nodeRegistration:
  name: "$HOSTNAME"
  criSocket: "unix:///var/run/containerd/containerd.sock"
  taints: []
  ignorePreflightErrors:
    - IsPrivilegedUser
  imagePullPolicy: "IfNotPresent"
localAPIEndpoint:
  advertiseAddress: "$ADVERTISE_ADDRESS"
  bindPort: 6443
certificateKey: "$CERTIFICATE_KEY"
timeouts:
  controlPlaneComponentHealthCheck: "60s"

---
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
kubernetesVersion: "stable"
controlPlaneEndpoint: "$CONTROL_PLANE_IP:6443"
clusterName: "example-cluster"
certificatesDir: "/etc/kubernetes/pki"
imageRepository: "registry.k8s.io"
encryptionAlgorithm: ECDSA-P256

networking:
  serviceSubnet: "10.96.0.0/16"
  podSubnet: "10.244.0.0/16"
  dnsDomain: "cluster.local"

etcd:
  external:
    endpoints:
$(for ip in "${ETCD_ENDPOINTS[@]}"; do echo "      - \"https://$ip:2379\""; done)
    caFile: "/etc/kubernetes/pki/etcd/ca.pem"
    certFile: "/etc/kubernetes/pki/etcd/etcd.pem"
    keyFile: "/etc/kubernetes/pki/etcd/etcd-key.pem"

apiServer:
  certSANs:
$(for name in "${CERT_SANS[@]}"; do echo "    - \"$name\""; done)

controllerManager: {}
scheduler: {}
dns: {}
proxy:
  disabled: true
EOF

echo "[✅] Đã ghi kubeadm-config.yaml:"
echo "--------------------------------------------"
cat kubeadm-configs.yaml
echo "--------------------------------------------"
