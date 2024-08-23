#!/bin/sh

echo  " _   _ _                 _                    _ _   _       _    ___       "
echo  "| | | | |__  _   _ _ __ | |_ _   _  __      _(_) |_| |__   | | _( _ ) ___  "
echo  "| | | | '_ \| | | | '_ \| __| | | | \ \ /\ / / | __| '_ \  | |/ / _ \/ __| "
echo  "| |_| | |_) | |_| | | | | |_| |_| |  \ V  V /| | |_| | | | |   < (_) \__ \ "
echo  " \___/|_.__/ \__,_|_| |_|\__|\__,_|   \_/\_/ |_|\__|_| |_| |_|\_\___/|___/ "

echo  

echo  " __  __           _              _   _           _       "
echo  "|  \/  | __ _ ___| |_ ___ _ __  | \ | | ___   __| | ___  "
echo  "| |\/| |/ _\` / __| __/ _ \ '__| |  \| |/ _ \ / _\` |/ _ \ "
echo  "| |  | | (_| \__ \ ||  __/ |    | |\  | (_) | (_| |  __/ "
echo  "|_|  |_|\__,_|___/\__\___|_|    |_| \_|\___/ \__,_|\___| "


sleep 5

echo  
echo "**** Config node master with K8s, Cri-o *****"
echo   

echo 
echo "**** Update repository package ****"
echo 

apt update
apt install -y ca-certificates curl apt-transport-https software-properties-common

echo 
echo "**** Disable Swap and Firewall ****"
echo 

sed -i '/swap/d' /etc/fstab
swapoff -a
systemctl disable --now ufw
modprobe br_netfilter
sysctl -w net.ipv4.ip_forward=1

echo 
echo "**** Install Cri-o ****"
echo 

KUBERNETES_VERSION=v1.30
PROJECT_PATH=prerelease:/main

curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list

curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/$PROJECT_PATH/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/$PROJECT_PATH/deb/ /" | tee /etc/apt/sources.list.d/cri-o.list

apt-get update
apt-get install -y cri-o
systemctl start crio.service

echo 
echo "**** Configure Cri-o proxy ****"
echo 

mkdir /etc/systemd/system/crio.service.d
cat <<EOF | sudo tee /etc/systemd/system/crio.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY="
Environment="HTTPS_PROXY="
Environment="NO_PROXY=10.0.0.0/8,169.254.0.0/16,172.16.0.0/12,192.168.0.0/16,127.0.0.0/8,localhost,127.0.0.1"
EOF

systemctl daemon-reload
systemctl restart crio

echo 
echo "**** Install K8s ****"
echo 

apt install -y kubelet kubeadm kubectl

echo 
echo "**** Init cluster ****"
echo 

kubeadm config images pull
kubeadm init

export KUBECONFIG=/etc/kubernetes/admin.conf

mkdir -p $HOME/.kube 
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown  $(id -u):$(id -g)  $HOME/.kube/config

echo 
echo "**** Install Calico network ****"
echo 

kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/manifests/calico.yaml

echo
echo "**** Install Kubectl autocomplete ****"
echo

source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc

echo 
echo "Finish install"
