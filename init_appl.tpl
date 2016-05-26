#!/bin/bash
echo "Start of boot script"
apt-get update
apt-get upgrade
wget https://raw.githubusercontent.com/relybv/dirict-role_appl/master/files/bootme.sh && bash bootme.sh
