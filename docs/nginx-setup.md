# NGINX Setup
NGINX is a free, open-source, high-performance webserver that can be used to serve content over the internet.

## Task
We were tasked with installing an NGINX webserver on our EC2 instance and configuring it to allow traffic on ports 80, 443, and 22. We were also tasked with configuring traffic to be redirected to port 443 when used on port 80.

## Installation
To install NGINX on our EC2 instance, we logged into the EC2 instance over SSH. To get the most recent package listings we used the command: "sudo apt-get update". To install NGINX onto our instance, we issued the command: "sudo apt-get install nginx" and accepted the installation.

## Configuring the firewall
In order to ensure traffic could reach our NGINX server on the ports we needed, we had to configure the Ubuntu firewall to allow traffic on those ports through. To list available application configurations known by Ubuntu issue the command: sudo ufw app list. On this list is a profile called "Nginx Full" which, if enabled, will allow traffic over both HTTo on port 80 and HTTPS on port 443. We enabled this porfile on the firewall by issuing the command: "sudo ufw allow 'Nginx Full'". The only port that remained to be added was SSH on port 22 which we added with the following command: "sudo ufw allow 22". Lastly, to enable the Ubuntu firewall we issued the command: "sudo yfw enable" and restarted NGINX with the command: "sudo systemctl restart nginx" to ensure the changes were applied.

## Redirecting traffic
The next step of setting up NGINX was ensuring that any traffic being sent on port 80 would automatically get redirected to port 443 to HTTPS. In order to accomplish this we had to add the following lines to /etc/nginx/sites-enabled/default:


``` if ($host ~ ^[^.]+\.matabit\.org$) {
        return 301 https://$host$request_uri;
     } # managed by Certbot
   ### using regex we find all the wildcard domains and then reroute them with a 301 message to the https version of that route

  listen 80;
  listen [::]:80; ### listening in to all http requests
  server_name matabit.org www.matabit.org blog.matabit.org; ### listen to all requests which request either of these dns names
  return 301 https://$host$request_uri; ### and reroute them to their https domain
}
```

We are using CertBot to automatically enable HTTPS on our webserver by listening for traffic on port 80 and automatically redirecting it to connect via HTTPS.

## Adding SSL certificates
The final step of configuring our NGINX webserver was adding the SSL certificates to our NGINX configuration file to allow for secure connections to the server.
The following lines were adding to the config file:
```server {
  listen 443 ssl; ### listen in to all https requests
  server_name www.matabit.org blog.matabit.org matabit.org; ### listen to all requests which request either of these dns name
    ssl_certificate /etc/letsencrypt/live/matabit.org/fullchain.pem; ### include the certificate
    ssl_certificate_key /etc/letsencrypt/live/matabit.org/privkey.pem; ### include the certificates private key
  include /etc/letsencrypt/options-ssl-nginx.conf;
  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

  root /var/www/matabit-blog/public; ### this is the root folder in which to load the index files listed below
  index index.html index.nginx-debian.html;

  location / {
    try_files $uri $uri/ =404; # try loading those files and if they don't load throw a 404
  }
}
```

Once these lines we added to the config file, it enabled any connection to our NGINX webserver over HTTPS to be encrypted over the network.