# AWS VPC SETUP

First off, a Virtual Private Cloud (VPC) is a section of the AWS cloud where you can launch and use AWS resources in. Basically, a virtual network.

We were tasked with setting up a VPC that consists of 3 public subnets, each with 1024 IP addresses, and 3 private subnets, each with 4096 IP addresses. Additionally, two route tables and an internet gateway (igw).

The entire VPC can be setup through the VPC Dashboard. 

Initially, you have to specify an IPv4 address range as a CIDR block, which basically sections off a part of the Amazon Cloud.

Since we need 3,072 (3x1,024) addresses for the public subnets and 12,288 (3x4,096) addresses for the private subnets, we decided that for a total of 15,360 we need a /18 CIDR block, which assigns the VPC 16,384 addresses.
This should cover all three availability zones sufficiently.

After the addresses were assigned to the VPC, we had to figure out what CIDR blocks were needed for the private and public subnets. For the public ones, we decided for a /22 block, which gives each public subnet 1024 addresses. For the private ones,we decided for a /20 block, which gives each private subnet 4096 addresses.

Here are the three public subnets
1. 132.124.0.0/22
2. 132.124.4.0/22
3. 132.124.8.0/22

Since each public subnet needs ~1024 addresses the third octet always increases by 4, since the 4th octet only covers 255 IPs (4*255 = 1020).

Here are the three private subnets
1. 132.124.16.0/20
2. 132.124.32.0/20
3. 132.124.48.0/20

Since each private subnet needs ~4096 addresses the third octet always increases by 16, since the 4th octet only covers 255 IPs (16*255 = 4080).

After all the private and public subnets were assigned, we made sure to create the correct routing tables.
The public subnet needs a routing table that allows for internet traffic. This is where the internet gateway comes in. 
The internet gateway needs to be created for the public routing table to allow internet access and route all outgoing traffic to 0.0.0.0/0.
After the internet gateway has been attached to the public routing table, we made sure that the public routing table was set as the main routing table, since most of the traffic is coming from the internet.

