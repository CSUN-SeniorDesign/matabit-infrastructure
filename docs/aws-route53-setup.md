# How to set up Route 53
Route 53 is AWS's manage Cloud DNS system. We use Route 53 to route traffic from the world into out Amazon instances, whether it be 
an EC2 or any other service provded. For our project, we registered a domain with Namecheap and we have Route 53 handling our DNS.
In order to get started, let's created a hosted zone.

# Creating a hosted zone
A hosted zone is an area where we can manage our DNS records. From the Route 53 management console. Click `hosted zones`. From
there, we can click `Create Hosted Zone`. A side panel will appear on the right side to define a Domain Name. For our project we
will use `matabit.org`. It's also a good practice to add comments for documentation purposes. As a `type`, we can define it to `Public
Hosted Zone`. From here you will see two records, `NS` which stands for Name servers and an `SOA` or Start of Authority. For now we
will focus on the Name Servers.

# Pointing domain to Route 53 Name servers
Keep the Route53 console open. Visit namecheap and login to our domain account. On the list of domains, click `Manage`. Under the 
Nameservers settings, change the `Namecheap BasicDNS` to `Custom DNS`. On the Route53 site, the NS records should contain 4 values that look like this:

```
ns-988.awsdns-59.net.
ns-1963.awsdns-53.co.uk.
ns-363.awsdns-45.com.
ns-1165.awsdns-17.org.
```

Add these records to the Namecheap DNS servers. These Nameservers allow proper routing to our EC2 instance

# Routing to our EC2 instance
Now that we have our domain's nameserver set up we can point records. From here we can create `A records` to point to our EC2's 
ElasticIP. Click `Create Record Set`, a menu should appear on the left. For the name  value you can set the APEX domain or subdomains. 
Example `blog`.matagit.org. As a `type`, you can leave it as an A Record. `Alias` set to no. TTL can be set to the default 300
seconds. In the `Value` field, enter the elastic IP from the EC2. This will configure requests the domain/subdomains to point
to the EC2.
