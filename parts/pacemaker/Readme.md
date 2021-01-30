

# testlab requirement
```
pcs property set stonith-enabled=false
pcs property set no-quorum-policy=ignore
```

# examples

```
# create virtual ips
pcs resource create vip10 ocf:heartbeat:IPaddr2 ip=11.11.11.10 cidr_netmask=32 op monitor interval=1s
pcs resource create vip20 ocf:heartbeat:IPaddr2 ip=11.11.11.20 cidr_netmask=32 op monitor interval=1s

# create a group "vip" and add vips
pcs resource group add vip vip10 vip20

# delete vip from group
pcs resource group remove vip vip20

# create a resource
pcs resource create haproxy ocf:heartbeat:haproxy binpath=$(which haproxy) conffile=/etc/haproxy/haproxy.cfg extraconf="-D -W -S /tmp/master-socket,uid,1000,gid,1000,mode,600" op monitor interval=1s failure-timeout=60s

# colocate haproxy with vip-group and set start order
pcs constraint colocation add haproxy with vip INFINITY
pcs constraint order start vip then start haproxy

# DRBD
pcs resource create drbd ocf:linbit:drbd drbd_resource="r0" op monitor interval=1s
pcs resource master drbd master-max=1 master-node-max=1 clone-max=2 clone-node-max=1 notify=true
pcs resource ban drbd centos3
pcs resource ban --master drbd-master centos3

# DRBD-Filesystem
pcs resource create fs_mysql Filesystem device="/dev/drbd0" directory="/var/lib/mysql" fstype="ext4"
pcs resource ban fs_mysql centos3
#?or pcs constraint location add lc_fs_mysql fs_mysql centos3 -INFINITY
pcs constraint order promote drbd-master then start fs_mysql
pcs constraint order start   drbd-master then start fs_mysql
pcs constraint colocation add fs_mysql with drbd-master INFINITY with-rsc-role=Master

# MySQL
pcs resource create mysql ocf:heartbeat:mysql \
  binary="/usr/bin/mysqld_safe" \
  config="/var/lib/mysql/conf/my.cnf" \
  datadir="/var/lib/mysql/data" \
  socket="/var/lib/mysql/mysql.sock" \
  log="/var/lib/mysql/mysqld.log" \
  pid="/var/lib/mysql/mysql.pid" \
  additional_parameters="--bind-address=0.0.0.0" \
  op start timeout=60s \
  op stop timeout=60s \
  op monitor interval=6s timeout=25s
pcs resource ban mysql centos3
pcs constraint colocation add mysql with fs_mysql INFINITY
pcs constraint order start fs_mysql then start mysql

# prefers
pcs constraint location vip prefers centos3=1
pcs constraint location vip prefers centos1=50
pcs constraint location vip prefers centos2=50
pcs constraint colocation add vip with fs_mysql 50
pcs constraint order start vip then start mysql
```
