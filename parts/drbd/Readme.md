## watch status
```
# colored stock
while true ; do  drbdadm status ; sleep 1; clear; done

# or
dnf -y install expect
watch --color 'unbuffer drbdadm status'
```
