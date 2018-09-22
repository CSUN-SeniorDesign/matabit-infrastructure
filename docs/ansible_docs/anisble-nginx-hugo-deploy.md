# Ansible kickstarter
Requirements 
* Ansible installed locally

## Writing the playbook
The playbook is the file that will contain the "stack" of what is to be deployed. For this project, we have a playbooks directory and roles directory in the Ansible directory. In the playbooks directory we have a project1 directory. This contains files: `ansible.cfg`, `hosts.ini` and `main.yml`. The `ansible.cfg` file contains default configurations for the playbook. `hosts.ini` is an inventory that contains the hostnames/IP address for the playbook to run against. The `main.yml`file contains the main playbooks that will execute with the `ansible-playbook` command. 

## Roles
Roles are separate functions or tasks that is used to provision a machine. It’s a good practice to use roles while making playbooks to keep functions separate. We have two main roles for the main playbook, install Nginx and deploy the Hugo blog.

## `ansible.cfg`
This file contain some of the default parameters for the project. We specified out host files so out playbook knows what hosts to run against. The roles path is also specified. For this project host key checking is disabled due to our bastion. 
```Ansible.
[defaults]
hostfile=hosts.ini
roles_path=../../roles
host_key_checking = False

[ssh_connection]
ssh_args = -C -o ControlMaster=auto -o ControlPersist=30m
```

## `hosts.ini`
This file contains the name of the servers out ansible script will run against along with an argument to allow use to locally run our Ansible playbook through the Bastion host.

```Ansible
[server]
EC2-1 ansible_host=matabit-ec2-1
EC2-2 ansible_host=matabit-ec2-2

[server:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q anthony@ssh.matabit.org"'
```

## `main.yml`
This file is the playbook that will run to provision a server. We give it a name and set a variable to use python3 by default as python2.7 in not installed. (On ubuntu 16.04 at least). Next well tell it to run on all hosts in the host inventory. Then we specify what roles to run.

```Ansible
---
- name: Install and deploy project1
  vars:
    ansible_python_interpreter: /usr/bin/python3
  hosts: all
  roles: 
    - update-cache
    - nginx-hugo
    - hugo
```

## Update cache role
This role is equal to running `sudo apt update` on a ubuntu machine. Required if we want to install out packages correctly
```Ansible
---
  - name: Update cache
    become: true
    apt:
      update_cache: yes
```

## Nginx-hugo role
This role install Nginx and takes a template file to change the default Nginx configuration to point to our matabit-blog directory. 

```Ansible
---
  - name: Install Nginx and Dependencies
    become: true
    apt:
      name: "{{ item }}"
      state: present
    with_items:
      - nginx
      - unzip
      - zip
      
  - name: Change Nginx default site settings
    become: true
    template:
      src: default
      dest: /etc/nginx/sites-available/default
  
  - name: Restart nginx
    become: true
    service: 
      name: nginx 
      state: restarted
```

## Hugo role
This role will deploy our blog. It first checks if the `/var/www/matabit-blog/public` directory exist, if not create it. The in takes our locally zipped Hugo blog and unzips it the directory created above. Next it sets the permission and owner of the directory to www-data. 
```Ansible
---
  - name: Check if /var/www/matabit-blog/public exist
    become: true
    file:
      path: /var/www/matabit-blog/public
      state: directory
    
  - name: Unzip public.zip 
    become: true
    unarchive:
      src: ~/CIT480/matabit-blog/public.zip
      dest: /var/www/matabit-blog/
  
  - name: Change hugo blog directory to www-data
    become: true
    file:
      path: /var/www/matabit-blog/public
      owner: www-data
      group: www-data
```

## Running the playbook
Make sure you built the latest version of the blog using the `build.sh` script found in the root of the project. Change directory to `Ansible/playbooks/project1`. Change any configurations such as hosts, user associated to connecting the SSH bastion, and blog zip directory. Now run `ansible-playbook main.yml` and watch the magic.
