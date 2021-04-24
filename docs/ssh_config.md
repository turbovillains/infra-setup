ssh_config.md
===

# Configure client for easier ssh

```
VerifyHostKeyDNS yes
VisualHostKey yes

Match exec "echo %h | egrep '^lab02-vm-(\w+)$'"
        Hostname %h.node.lab02.noroutine.me

```