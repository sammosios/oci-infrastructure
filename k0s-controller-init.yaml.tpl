#cloud-config
package_update: true
package_upgrade: true

packages:
  - curl

runcmd:
  - echo "Starting k0s controller installation..."
  - curl -sSLf https://get.k0s.sh | sh
  - echo "k0s installation script finished. Checking for k0s binary..."
  - test -f /usr/local/bin/k0s && echo "k0s binary found"
  - /usr/local/bin/k0s install controller
  - systemctl enable k0scontroller
  - systemctl start k0scontroller
  - iptables -I INPUT 4 -p tcp --dport 6443 -s 10.0.0.0/16 -j ACCEPT
  - echo "Finished cloud-init script for controller"
