#!/bin/bash

# Do only on node1 and node2
case $HOSTNAME in *3) exit 0 ;; esac

if lsblk | grep sdb
then
  pvcreate /dev/sdb
  vgcreate drbd /dev/sdb
  lvcreate --name data --size 5G drbd
else
  echo "no sdb found."
  exit 0
fi

dnf -y install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
dnf -y install drbd drbd-utils kmod-drbd90 lvm2

depmod -a && modprobe drbd

cat >/etc/drbd.d/r0.res <<EOF
resource r0 {
  device    /dev/drbd0;
  disk      /dev/mapper/drbd-data;
  meta-disk internal;
  on centos1 { address 11.11.11.11:7789; }
  on centos2 { address 11.11.11.12:7789; }
}
EOF

drbdadm create-md r0 && drbdadm up r0

case $HOSTNAME in *1)
  drbdadm primary --force r0
  mkfs.ext4 /dev/drbd0  
  ;; 
esac
