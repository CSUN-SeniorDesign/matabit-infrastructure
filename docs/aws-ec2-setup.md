# AWS EC2 Setup
EC2, or Elastic Compute Cloud, is a virtual machine within Amazon's computing environment that can be used to host webservers.

## Task
We were tasked these past two weeks to setup an EC2 instance through AWS and configure it according to what would be needed.

## Creating the instance
We created our EC2 instance using a t2.micro instance in the us-west-2b availibility zone. EC2 micro instances are free to use and should be sufficient enough for the purposes of this project. For the instance we decided to go with an Ubuntu 16.04 LTS AMI (Amazon Machine Image) installation with a 16GB volume (gp2).

## Creating a security group
To monitor incoming and outgoing traffic to and from our EC2 instance we setup a security group called "matabit-sg" within the matabit-vpc. We set the inbound rules as follows:
(HTTP) Port 80 allows traffic from 0.0.0.0/0
(HTTPS) Port 443 allows traffic from 0.0.0.0/0
(SSH) Port 22 allows traffic from 0.0.0.0/0

This was setup this way to allow users to access hosted webpages over HTTP and HTTPS from any IP address on the internet. This allows our web content to be available to anyone who would like to access it. We also allowed incoming connections over SSH so that those with proper access can remotely access and maintain the server over SSH from any IP as long as their SSH key was added to the list of authorized keys.

We set the outbound rules as follows:
All traffic, all protocols, and all port ranges going out to 0.0.0.0/0.
This is set up this way to allow our webserver to be flexible and host a variety of content to any IP on the internet.

## Elastic IP
AWS allows for the assignment of elastic IP addresses which can be bound and detached from EC2 instances. We retrieved an elastic IP (52.33.139.75) and associated it with our EC2 instance by its ID (i-08f2978c0a0fde99e). Now that we have an elastic IP assigned to our EC2 instance we can have our domain names matabit.org, www.matabit.org, and blog.matabit.org point to it.

## SSH access
The final step was configuring our EC2 instance to allow access over SSH to run commands to setup and maintain the server. To accomplish this, we each generated SSH keys on our local machines using keygen and added our public keys into the VPC at /home/ubuntu/.ssh/authorized_keys. Once these keys were added, we could access our EC2 instance via SSH remotely from our local machines.