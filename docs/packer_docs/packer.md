# Packer

We are using Packer to establish a baseline AMI.

Packer in our case takes an array of `builders` and an array of `provisioners`.

We are only declaring one builder in this instance, and we basically describe in which VPC, Subnet and Region to build the EC2 instance and additonal details such as AMI name and what type of EC2 instance we want.

The `provisioners` array takes multiple values that describe what to execute on startup.


```JSON
{   
    "provisioners": [
        {
            "type": "shell",
            "script": "provision.sh"
        },
        {
            "type": "ansible-local",
            "playbook_dir": "../Ansible",
            "playbook_file": "../Ansible/playbooks/project2/playbook.yml" 
        }
    ],
    "builders": [{
        "type": "amazon-ebs",
        "region": "us-west-2",
        "source_ami": "ami-0bbe6b35405ecebdb",
        "instance_type": "t2.micro",
        "vpc_id": "vpc-0553d43b1f13cc99e",
        "subnet_id": "subnet-0a397f709535c5773",
        "ssh_username": "ubuntu",
        "ami_name": "matabit-ami {{timestamp}}"
    }]
}
```


The entire playbook directory and the shell script get uploaded to the remote instance and then executed locally. The shell provisioner is responsible for the initial setup.


```JSON
  "provisioners": [
        {
            "type": "shell",
            "script": "provision.sh"
        },
        {
            "type": "ansible-local",
            "playbook_dir": "../Ansible",
            "playbook_file": "../Ansible/playbooks/project2/playbook.yml" 
        }
    ]
```

## The Shell Provisioner
```bash
#!/bin/bash
set -e
#provision.sh
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y python-dev python-pip
sudo pip install ansible
sudo DD_API_KEY=<API-KEY> bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/datadog-agent/master/cmd/agent/install_script.sh)"
```
The provisioner script does the initial setup by installing python dev dependencies so that we can install ansible. Additionally, it installs the datadog-agent.

After the shell provisioner is executed on the EC2 Instance, it continues with the Ansible provisioner.

## The Ansible Provisioner

```YAML
---
- name: Run the playbook tasks on the localhost
  hosts: 127.0.0.1
  connection: local
  roles: 
    - update-cache
    - nginx
    - mkdir-env
    - establish-index-nginx
    - nginx-hugo
    - install-aws-cli
    - configure-datadog
    - ec2-get-blog
```

This is the playbook that we’re running. Essentially, we’re making sure that the ansible script runs on the localhost and then run all the roles in order. The most essential new additions are the install-aws-cli role, configure-datadog, and ec2-get-blog.

