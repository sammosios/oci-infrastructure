#cloud-config
package_update: true
package_upgrade: true

packages:
  - curl

runcmd:
  - curl -sSLf https://get.k0s.sh | sh
  - k0s install controller --single
  - systemctl enable k0scontroller
  - systemctl start k0scontroller
