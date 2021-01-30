#!/bin/bash

NODES=3
NAME=centos

dnf -y --enablerepo=ha -y install pacemaker pcs

cat > /etc/corosync/corosync.conf <<'EOF'
totem {
    version: 2
    cluster_name: hacluster
    secauth: off
    transport: udpu

    interface {
      ringnumber: 0
      bindnetaddr: 11.11.11.0
      mcastport: 5405
      broadcast: yes
    }
}

quorum {
    provider: corosync_votequorum
}

logging {
    to_logfile: yes
    logfile: /var/log/corosync.log
}

nodelist {

    node {
        ring0_addr: centos1
        nodeid: 1
    }

    node {
        ring0_addr: centos2
        nodeid: 2
    }

    node {
        ring0_addr: centos3
        nodeid: 3
    }

}
EOF

systemctl enable corosync --now
systemctl enable pacemaker --now
systemctl enable pcsd --now

systemctl restart corosync
systemctl restart pacemaker
systemctl restart pcsd

case $HOSTNAME in
  *3)
    sleep 10

    pcs property set stonith-enabled=false
    pcs property set no-quorum-policy=ignore

    pcs resource create vip ocf:heartbeat:IPaddr2 ip=11.11.11.10 cidr_netmask=32 op monitor interval=1s
  ;;
esac
