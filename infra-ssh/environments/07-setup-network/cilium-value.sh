#!/bin/bash
set -e

### === THAM SỐ CẦN TRUYỀN === ###
# $1  - SERVER_HOST
##################################

SERVER_HOST="$1"

echo "[ START ] created cilium-value.yaml..."

cat <<EOF | sudo tee /tmp/cilium-value.yaml > /dev/null
ipam:
  mode: kubernetes
  operator:
    enabled: true

routingMode: native
autoDirectNodeRoutes: true
ipv4NativeRoutingCIDR: 10.244.0.0/16

kubeProxyReplacement: true
k8sServiceHost: "$SERVER_HOST"
k8sServicePort: 6443

gatewayAPI:
  enabled: true
  gatewayAPIClassName: cilium

bgpControlPlane:
  enabled: true
  devices: "enp0s3"

envoy:
  enabled: true
  securityContext:
    capabilities:
      keepCapNetBindService: true
      envoy:
        - NET_BIND_SERVICE
        - NET_ADMIN
        - BPF
debug:
  enabled: true
EOF

echo -e "\e[34m[ DONE ] GEN cilium-value.yaml \e[0m"
echo "--------------------------------------------"
cat /tmp/cilium-value.yaml
echo "--------------------------------------------"
