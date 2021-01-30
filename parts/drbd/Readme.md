## watch status
```
# colored stock
while true ; do  drbdadm status ; sleep 1; clear; done

# or 
# watch with colors
dnf -y install expect
watch --color 'unbuffer drbdadm status'
# without colors
watch drbdadm status
```
