#!/usr/bin/bash
sudo apt-key del 90CFB1F5
sudo apt-get autoremove -y --purge  mongodb-org-tools &> /dev/null
sudo rm -rf /etc/apt/sources.list.d/mongodb-org-4.4.list &> /dev/null
sudo apt-get update > /dev/null
