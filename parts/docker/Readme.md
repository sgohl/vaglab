# examples

```
docker service create --name nginx --publish 88:80 --constraint 'node.role == manager' nginx:alpine
```

## curl test
```
while true; do for s in 11.11.11.11 11.11.11.12 11.11.11.13; do curl -I -m 1 --connect-timeout 1 $s:88 ; echo $s; sleep 1; done ; done
```
