#!/bin/bash
mkdir -p ${playbook_dir}
chown ${user} ${playbook_dir}

apt-get update
apt-get install -y \
    docker-compose \
    ansible

ansible-galaxy collection install community.docker
