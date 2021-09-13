str=`tail -1 /tmp/tmpMaster1Init.sh`
cat /tmp/tmpMaster1Init.sh | sed -n '/Then you can join any number of worker nodes by running the following on each as root:/,/$str/p' > /tmp/tmpWorkerInit.sh
sed -i 's/Then you can join any number of worker nodes by running the following on each as root://'  /tmp/tmpWorkerInit.sh
mkdir -p $HOME/.kube
sudo chown $(id -u):$(id -g) $HOME/.kube/config