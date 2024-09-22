#!/usr/bin/bash
apt update -y

sudo apt-get install curl gnupg apt-transport-https wget net-tools telnet unzip jq  gettext git python3-pip -y

# install aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
echo "$UD install aws cli and jq finished"

# Install K8S Cluster
private_ip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
git clone https://github.com/kubespray/kubespray.git
cd kubespray && \
  pip install -r requirements.txt && \
  pip install --no-deps ruamel.yaml && \
  export ANSIBLE_HOST_KEY_CHECKING=False && \
  cp -rfp inventory/sample inventory/mycluster && \
  declare -a IPS=$private_ip && \
  CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]} && \
  cat inventory/mycluster/group_vars/all/all.yml && \
  cat inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml && \
  ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root cluster.yml -e "ansible_connection=local"

## Install Helm Command
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

## Install Ingress Nginx
kubectl create ns ingress-nginx
helm install ingress-nginx  \
  --set ingressClassResource.default=true \
  --set service.type=NodePort \
  --set service.nodePorts.http=32080 \
  --set service.nodePorts.https=32443 \
  --set metrics.enabled=true \
  --set kind=DaemonSet \
  oci://registry-1.docker.io/bitnamicharts/nginx-ingress-controller \
  -n ingress-nginx

## Install kube-prometheus-stack monitoring
kubectl create ns monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --set grafana.ingress=true \
  --set grafana.ingress.hosts="grafana.prod.elsa.com" \
  --set grafana.ingress.ingressClassName="nginx" \
  -n monitoring

## Install grafana loki logging
cat <<EOF > loki-values.yml
loki:
  schemaConfig:
    configs:
      - from: 2024-04-01
        store: tsdb
        object_store: s3
        schema: v13
        index:
          prefix: loki_index_
          period: 24h
  ingester:
    chunk_encoding: snappy
  tracing:
    enabled: true
  querier:
    # Default is 4, if you have enough memory and CPU you can increase, reduce if OOMing
    max_concurrent: 4

#gateway:
#  ingress:
#    enabled: true
#    hosts:
#      - host: FIXME
#        paths:
#          - path: /
#            pathType: Prefix

deploymentMode: Distributed

ingester:
  replicas: 3
querier:
  replicas: 3
  maxUnavailable: 2
queryFrontend:
  replicas: 2
  maxUnavailable: 1
queryScheduler:
  replicas: 2
distributor:
  replicas: 3
  maxUnavailable: 2
compactor:
  replicas: 1
indexGateway:
  replicas: 2
  maxUnavailable: 1

bloomCompactor:
  replicas: 0
bloomGateway:
  replicas: 0

# Enable minio for storage
minio:
  enabled: true

# Zero out replica counts of other deployment modes
backend:
  replicas: 0
read:
  replicas: 0
write:
  replicas: 0

singleBinary:
  replicas: 0
EOF

helm repo add grafana https://grafana.github.io/helm-charts
helm install loki grafana/loki --values loki-values.yml -n monitoring
