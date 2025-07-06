#cloud-config
package_update: true
package_upgrade: true

packages:
  - curl

write_files:
  - path: /tmp/worker-token.txt
    permissions: '0600'
    content: |
      ${worker_token}

runcmd:
  - curl -sSLf https://get.k0s.sh | sh
  - k0s install worker --token-file /tmp/worker-token.txt
  - systemctl enable k0sworker
  - systemctl start k0sworker

