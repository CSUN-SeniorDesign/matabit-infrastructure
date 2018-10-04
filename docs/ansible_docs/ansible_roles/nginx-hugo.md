# Configure NGINX for hugo

```YAML
---
  - name: Install Nginx and Dependencies
    become: true
    apt:
      name: "{{ item }}"
      state: present
    with_items:
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

Here we are simply installing the dependencies for Hugo (`zip`, `unzip`).

With the `template` module we can put our own default configuration for NGINX onto the EC2 Instance.

Lastly, with the `service` module we can restart NGINX so that it actually registers the new NGINX configuration.

## Below is the `default` template that we are using to configure NGINX

```NGINX
server {
	listen 80;
	listen [::]:80;
	root /var/www/prod/matabit-blog/public;
	server_name www.matabit.org blog.matabit.org matabit.org;
	index index.html index.htm index.nginx-debian.html;

	location / {
		try_files $uri $uri/ =404;
		add_header X-Hostname $hostname;
		add_header X-Private-IP $server_addr;
	}
}

server {
	listen 80;
	listen [::]:80;
	root /var/www/staging/matabit-blog/public;
	server_name www.staging.matabit.org blog.staging.matabit.org staging.matabit.org;
	index index.html index.htm index.nginx-debian.html;

	location / {
		try_files $uri $uri/ =404;
		add_header X-Hostname $hostname;
		add_header X-Private-IP $server_addr;
	}
}

server {
  listen 81;
  server_name localhost;

  access_log off;
  allow 127.0.0.1;
  deny all;

  location /nginx_status {
    stub_status;
  }
}
```

We have added `X-Hostname` and `X-Private-IP` headers to identify which server the response is coming from.