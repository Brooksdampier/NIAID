#!/bin/bash

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0E08A149DE57BFBE 

echo "deb  [trusted=yes] https://repo.saltproject.io/py3/ubuntu/18.04/amd64/latest bionic main" | sudo tee /etc/apt/sources.list.d/salt.list

apt update

apt -y install salt-minion

rm -f /etc/salt/minion

cd /etc/salt

wget https://raw.githubusercontent.com/Brooksdampier/NIAIDPROD/master/minion

systemctl restart salt-minion
