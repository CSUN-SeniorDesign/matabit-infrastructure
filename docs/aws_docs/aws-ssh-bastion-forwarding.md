# How to ssh forward into our Private EC2 using the bastion
This assumes you have a personal SSH key pair generated. Also your public key has been added to the cloud-init file.

# Add your ssh private key to your ssh-agent
To add your ssh key to your ssh-agent run `ssh-add -K ~/.ssh/id_rsa`. The previous command works for Mac/BSD. On linux use `ssh-add ~/.ssh/id_rsa`.

# Enable SSH-forwarding
Now to ssh-forward, add the -A flag while sshing. Example: `ssh -A anthony@ssh.matabit.org` you should now be in the ssh bastion. 
From here you can ssh into the private instances as long as the cloud-init is configured correctly. Simply `ssh anthony@private-ip-or-dns-name` and you should be in the private EC2 instance. 
