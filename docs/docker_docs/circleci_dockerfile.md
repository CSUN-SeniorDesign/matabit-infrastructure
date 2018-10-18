# Install Docker

### Install Docker by following this [guide](https://docs.docker.com/install/).


# Basic Commands

## To build a docker image run...

```bash
docker build -t myapp:latest .
```

## To tag a local image witha new image name and tag

```bash
docker tag image:tag repo/newimage:newtag
```

## To push a docker image into a registry...
```bash
docker push repo/image:tag
```

# What We Need

We need three Docker images:
1. CircleCI 
2. Matabit-Blog
    - Production Image
    - Staging Image


## CircleCI Dockerfile
We need a separate CircleCI image to be able to run hugo commands, build our docker image, and then push it to AWS.

We used the following Dockerfile to create our new CircleCI image.

```bash
FROM cibuilds/hugo
RUN apk update && apk add git python python-dev py-pip build-base \
    && pip install --upgrade pip \
    && pip install awscli \
    && apk add docker
```

## Matabit-Blog Dockerfile
We used one dockerfile with separate arguments to establish the two environments. 

It is recommended to use as few `RUN` commands as possible because each command will add another layer onto the image which will make it larger than necessary. However, if you chain the bash commands into a single `RUN` command you can reduce the bloat.

```
# nginx image built on top of alpine linux
FROM nginx:alpine

ARG BUILD_VAR

# Create environment folders and copy index file for test
RUN mkdir -p "/var/www/staging/matabit-blog/public" \
    && mkdir -p "/var/www/prod/matabit-blog/public" \
    && cp /usr/share/nginx/html/index.html \
       /var/www/prod/matabit-blog/public \
    && cp /usr/share/nginx/html/index.html \
        /var/www/staging/matabit-blog/public

# Copy content of public folder to docker image
COPY public /var/www/$BUILD_VAR/matabit-blog/public

# add custom nginx config
COPY nginx.template /etc/nginx/conf.d/default.conf

# expose port 80 for HTTP
EXPOSE 80
```

