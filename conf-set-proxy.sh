sudo apt update && sudo apt install -y haproxy
sudo chmod 777 /etc/haproxy/haproxy.cfg
cat >/etc/haproxy/haproxy.cfg<<EOF
listen stats
    bind    192.168.56.111:8090
    mode    http
    stats   enable
    stats   hide-version
    stats   uri       /stats
    stats   refresh   30s
    stats   realm     Haproxy\ Statistics
    stats   auth      admin:admin

frontend kubernetes-frontend
    bind 192.168.56.111:6443
    mode tcp
    option tcplog
    default_backend kubernetes-backend

backend kubernetes-backend
    mode tcp
    option tcp-check
    balance roundrobin
    server kmaster1 192.168.56.101:6443 check fall 3 rise 2
    server kmaster2 192.168.56.102:6443 check fall 3 rise 2

frontend web-kubernetes-frontend
    bind 192.168.56.111:8443
    mode tcp
    option tcplog
    default_backend web-kubernetes-backend

backend web-kubernetes-backend
    mode tcp
    option tcp-check
    balance roundrobin
    server kmaster1 192.168.56.101:8443 check fall 3 rise 2
    server kmaster2 192.168.56.102:8443 check fall 3 rise 2
EOF
sudo chmod 644 /etc/haproxy/haproxy.cfg
sudo systemctl restart haproxy