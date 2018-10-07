# Ansible-Playbook

```
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

The ansible playbook is running on the local host as indicated by `hosts: 127.0.0.1`.
This playbook is for the EC2 Instance that Packer is creating.

For more details on the roles that are being executed click on any of the links below.
1. [update-cache](ansible_roles/update-cache.md)
2. [nginx](ansible_roles/nginx.md)
3. [mkdir-env](ansible_roles/mkdir-env.md)
4. [establish-index-nginx](ansible_roles/establish-index-nginx.md)
5. [nginx-hugo](ansible_roles/nginx-hugo.md)
6. [install-aws-cli](ansible_roles/install-aws-cli.md)
7. [configure-datadog](ansible_roles/configure-datadog.md)
8. [ec2-get-blog](ansible_roles/ec2-get-blog.md)
