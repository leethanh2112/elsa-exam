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



