cat >/etc/hosts<<EOF
127.0.0.1      localhost
192.168.56.111 loadbalancer.rean52.com  loadbalancer
192.168.56.101 kmaster1.rean52.com      kmaster1
192.168.56.102 kmaster2.rean52.com      kmaster2
192.168.56.201 kworker1.rean52.com      kworker1
EOF