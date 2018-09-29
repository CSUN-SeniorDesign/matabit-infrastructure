#!/bin/bash
set -e
#provision.sh
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y python-dev python-pip
sudo pip install ansible