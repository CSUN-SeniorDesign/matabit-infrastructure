#!/bin/bash
set -e
#provision.sh
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y python-dev python-pip
sudo pip install ansible
sudo DD_API_KEY=1d84e240931097df601c6888b501c0b4 bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/datadog-agent/master/cmd/agent/install_script.sh)"