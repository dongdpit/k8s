#!/bin/sh

echo 
echo "**** Check and backup old certs ****"
echo 

kubeadm certs check-expiration
cp -rp /etc/kubernetes /root/old_k8s_config

echo 
echo "**** Renew certs ****"
echo 

kubeadm certs renew all 
kubeadm certs check-expiration

echo 
echo "**** Re-generate certs ****"
echo 

rm -rf /etc/kubernetes/*.conf
kubeadm init --kubernetes-version=v1.30.4 phase kubeconfig all

echo 
echo "**** Re-export config ****"
echo 

export KUBECONFIG=/etc/kubernetes/admin.conf

mkdir -p $HOME/.kube 
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown  $(id -u):$(id -g)  $HOME/.kube/config

echo 
echo "Finish renew"
