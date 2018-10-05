# Copying index.html files

We are copying the index.html files for testing to the root environment folders for NGINX.

```YAML 
---
- name: Copy index.nginx-debian.html to the prod folder
  become: true
  command: cp /var/www/html/index.nginx-debian.html /var/www/prod/matabit-blog/public/index.nginx-debian.html 
  
- name: Copy index.nginx-debian.html to the staging folder
  become: true
  command: cp /var/www/html/index.nginx-debian.html /var/www/staging/matabit-blog/public/index.nginx-debian.html
```

These are simply bash commands being run by ansible. No special modules used here.

