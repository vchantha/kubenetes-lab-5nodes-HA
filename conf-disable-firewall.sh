sudo ufw disable
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab