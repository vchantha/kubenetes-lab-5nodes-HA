# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_NO_PARALLEL'] = ''

## public declare :
$script_windows = <<SCRIPT
. sc.exe config winrm start= auto
iwr -useb https://chocolatey.org/install.ps1 | iex
choco install -y azure-cli
echo "___1_HelloRunningScript!___"
SCRIPT

$shell_linux = <<-SHELL
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

$win_disable_firewall =<<SCRIPT
# Disable Windows Firewall
netsh advfirewall set allprofiles state off
SCRIPT

Vagrant.configure(2) do |config|
  ## global : 
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.boot_timeout = 6000

  # Load Balancer Node
  LoadCount = 2
  (1..LoadCount).each do |i|
    config.vm.define "load#{i}" do |lb|
      lb.vm.box = "bento/ubuntu-20.04"
      lb.vm.hostname = "load#{i}.yangtom.com"
      lb.vm.network "private_network", ip: "192.168.56.11#{i}"
      lb.vm.provider "virtualbox" do |v|
        v.name = "load#{i}"
        v.memory = 1024
        v.cpus = 1
        v.gui = false
      end
      lb.vm.provision "shell", inline: $shell_linux
    end
  end

  MasterCount = 2
  (1..MasterCount).each do |i|
    config.vm.define "master#{i}" do |masternode|
      masternode.vm.box = "bento/ubuntu-20.04"
      masternode.vm.hostname = "master#{i}.yangtom.com"
      masternode.vm.network "private_network", ip: "192.168.56.10#{i}"
      masternode.vm.provider "virtualbox" do |v|
        v.name = "master#{i}"
        v.memory = 2048
        v.cpus = 1
        v.gui = false
      end
      masternode.vm.provision "shell", inline: $shell_linux
    end
  end

  NodeCount = 3
  (1..NodeCount).each do |i|
    config.vm.define "worker#{i}" do |workernode|
      workernode.vm.box = "bento/ubuntu-20.04"
      workernode.vm.hostname = "worker#{i}.yangtom.com"
      workernode.vm.network "private_network", ip: "192.168.56.20#{i}"
      workernode.vm.provider "virtualbox" do |v|
        v.name = "worker#{i}"
        v.memory = 1024
        v.cpus = 1
        v.gui = false
      end
      workernode.vm.provision "shell", inline: $shell_linux
    end
  end 
  ## per section :
  WinCount = 2
  (1..WinCount).each do |i|
    config.vm.provision "shell", inline: $win_disable_firewall
    config.vm.define "svr#{i}" do |win|
      win.vm.box = "cdaf/WindowsServerDC"
      # use the plaintext WinRM transport and force it to use basic authentication.
      # NB this is needed because the default negotiate transport stops working
      #    after the domain controller is installed.
      #    see https://groups.google.com/forum/#!topic/vagrant-up/sZantuCM0q4
      ## https://github.com/bitfrickler/vagrant-active-directory-2016/blob/master/Vagrantfile
      win.winrm.transport = :plaintext
      win.winrm.basic_auth_only = true
      win.vm.communicator = "winrm"
      win.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true
      win.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true
      win.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
      win.vm.guest = :windows 
      win.vm.hostname = "svr#{i}"
      win.vm.network "private_network", ip: "192.168.56.1#{i}"
      win.vm.provider "virtualbox" do |v|
        v.name = "svr#{i}"
        v.memory = 2048
        v.gui = false
      end
      win.vm.provision "shell", inline: $script_windows, privileged: true, powershell_elevated_interactive: true
      win.vm.provision "shell", inline: $win_disable_firewall, privileged: true, powershell_elevated_interactive: true
    end
  end


end
