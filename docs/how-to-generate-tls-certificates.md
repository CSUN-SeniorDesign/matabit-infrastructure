# How to generate TLS/SSL certificates


## What We Need To Do
We were tasked to obtain a TLS certificate for the following domains

```
matabit.org
www.matabit.org
blog.matabit.org
```

To simplify the process for these and any future domains, we need to obtain a wildcard certificate.

## Where We Get The Certificate
The certificate authority that we use is [Let's Encrypt](https://letsencrypt.org/).
To request these certificates on our AWS EC2 instance, we use [Certbot](https://certbot.eff.org/lets-encrypt/ubuntuxenial-nginx).

## To install Certbot run the following commands:

```
$ sudo apt-get update
$ sudo apt-get install software-properties-common
$ sudo add-apt-repository ppa:certbot/certbot
$ sudo apt-get update
$ sudo apt-get install python-certbot-nginx
```

This installs all the necessary dependencies to run certbot on the server and request the certificates.

## Request The Ceritficate
Afterwards, we can run the following command to request the certificate:

```
$ sudo certbot certonly --manual -d *.matabit.org -d matabit.org -m dev@anthonyinlavong.com --preferred-challenges dns-01 --server https://acme-v02.api.letsencrypt.org/directory
```

`certonly` will only obtain the certificate and not install it.
`--manual` will prompt to obtain the certificate interactively.
`-d` will specify for which domain the certificate has to be obtained (can be chained with multiple declarations)
`-m` the email used for registration/recovery, preferrably the one used to register the domain
`--preferred-challenges` will specify a protocol to challenge the control of a domain
`--server` the acme directory that will issue the certificate

The certificate files can be then found in `/etc/letsencrypt/matabit.org/live/*`.

## Configure NGINX
These certificates then have to be called within the nginx-configuration of the web-server,
like this:

```
ssl_certificate /etc/letsencrypt/live/matabit.org/fullchain.pem; # managed by Certbot
ssl_certificate_key /etc/letsencrypt/live/matabit.org/privkey.pem; # managed by Certbot
```

Lastly, restart nginx.
