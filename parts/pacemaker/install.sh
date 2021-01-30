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
}

quorum {
    provider: corosync_votequorum
}

logging {
    to_logfile: yes
    logfile: /var/log/corosync.log
    to_syslog: yes
}

nodelist {
EOF

unset CONF
for (( i=1; i <= ${NODES} ; i++ )); do
CONF+="
    node { 
        ring0_addr: ${NAME}${i}
        nodeid: ${i}
    }    
"
done
# tbd: generate with jo/jq

echo "$CONF" | tee -a /etc/corosync/corosync.conf
echo "}" | tee -a /etc/corosync/corosync.conf


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
