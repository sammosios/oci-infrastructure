#cloud-config
package_update: true
package_upgrade: true

packages:
  - curl

runcmd:
  - curl -sSLf https://get.k0s.sh | sh
  - /usr/local/bin/k0s install controller
  - systemctl enable k0scontroller
  - systemctl start k0scontroller
  - iptables -I INPUT 4 -p tcp --dport 6443 -s 0.0.0.0/0 -j ACCEPT