# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure(2) do |config|
 
 
config.vm.boot_timeout = 6000 

# Global reset password root
### start inline >>>> 
config.vm.provision "shell", inline: <<-SHELL
echo "===> start password ROOT ... <==="
cat <<EOF | sudo passwd root
bigdata
bigdata
EOF
sudo chmod 777 /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo chmod 644 /etc/ssh/sshd_config
sudo systemctl restart sshd
echo "===> reset password ROOT success <==="
SHELL
### end inline <<<< 

### start batch script >>>> 
  ## disable firewall
  config.vm.provision "shell", path: "conf-disable-firewall.sh"
  ## set bridg paramter
  config.vm.provision "shell", path: "conf-netb-kub.sh"
  ## set /etc/hosts/
  config.vm.provision "shell", path: "conf-set-host.sh"
  ## pre install
  config.vm.provision "shell", path: "conf-pre-install.sh"
  ## add repo
  config.vm.provision "shell", path: "conf-set-repo.sh"
  ## install
  config.vm.provision "shell", path: "conf-post-install.sh"
  ## update
  config.vm.provision "shell", path: "conf-update-os.sh"
### end batch script <<<<

  # Load Balancer Node
  config.vm.define "loadbalancer" do |lb|
    lb.vm.box = "bento/ubuntu-20.04"
    lb.vm.hostname = "loadbalancer.rean52.com"
    lb.vm.network "private_network", ip: "192.168.56.111"
    lb.vm.provider "virtualbox" do |v|
      v.name = "loadbalancer"
      v.memory = 1024
      v.cpus = 1
      v.gui=false
    end ## end provider
    lb.vm.provision "shell", path: "conf-set-proxy.sh"
  end ## end define loadbalancer

  MasterCount = 2

  (1..MasterCount).each do |i|
    config.vm.define "kmaster#{i}" do |masternode|
      masternode.vm.box = "bento/ubuntu-20.04"
      masternode.vm.hostname = "kmaster#{i}.rean52.com"
      masternode.vm.network "private_network", ip: "192.168.56.10#{i}"
      masternode.vm.provider "virtualbox" do |v|
        v.name = "kmaster#{i}"
        v.memory = 2048
        v.cpus = 2
        v.gui=false
      end ## end provider
    end ## end loop master
  end ## end define master

  NodeCount = 2

  # Kubernetes Worker Nodes
  (1..NodeCount).each do |i|
    config.vm.define "kworker#{i}" do |workernode|
      workernode.vm.box = "bento/ubuntu-20.04"
      workernode.vm.hostname = "kworker#{i}.rean52.com"
      workernode.vm.network "private_network", ip: "192.168.56.20#{i}"
      workernode.vm.provider "virtualbox" do |v|
        v.name = "kworker#{i}"
        v.memory = 1024
        v.cpus = 1
        v.gui=false
      end ## end provider
    end ## end loop Worker
  end ## end define Worker

end ## end Vagrant.configure
