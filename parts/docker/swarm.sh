#!/bin/bash

dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf -y install docker-ce
systemctl enable --now docker

case $HOSTNAME in
  *1)
    docker swarm init --advertise-addr 11.11.11.11
    docker swarm join-token manager | grep join | tee /vagrant/.swarm-token-manager
    ;;
   *2|*3)
   until [[ -f /vagrant/.swarm-token-manager ]] && docker ps; do sleep 1 ; done
   bash /vagrant/.swarm-token-manager
 esac
