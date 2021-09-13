#!/bin/bash
cat /dev/null > /tmp/tmpMaster1Init.sh 
kubeadm init --control-plane-endpoint="192.168.56.111:6443" --upload-certs --apiserver-advertise-address=192.168.56.101 --pod-network-cidr=192.168.0.0/16 >> /tmp/tmpMaster1Init.sh 
cat /tmp/tmpMaster1Init.sh | sed -n '/You can now join any number of the control-plane node running the following command on each as root:/,/Please note that the certificate-key gives access to cluster sensitive data, keep it secret!/p' > /tmp/tmpMaster2Init.sh
sed -i 's/You can now join any number of the control-plane node running the following command on each as root:/####==> You can now join any number of the control-plane node running the following command on each as root:/' /tmp/tmpMaster2Init.sh
sed -i 's/Please note that the certificate-key gives access to cluster sensitive data, keep it secret!/####==> Please note that the certificate-key gives access to cluster sensitive data, keep it secret!/'  /tmp/tmpMaster2Init.sh
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
