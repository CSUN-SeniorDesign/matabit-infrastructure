# How to deploy a blog post to production

## Requirements:
 * Hugo
 * SSH access to EC2 Production server
 * zip and unzip installed on both dev and production
 * Do not use git clone and preferably not git pull

## Easymode
I've created a bash script to easily deploy new blog posts into production. I will also add documentation for the manual method.
First in the matabit-blog repo. Allow the execution of the `deploy.sh` script by running `chmod +x deploy.sh`. Run the script
with `./deploy.sh`. Now watch the magic as the blog post builds and deploys into production. Below are the contents of the bash script. 

To break it down:
  * Runs `hugo` locally to build pages in the public directory
  * Zips the `public/` directory as `public.zip`
  * Transfer zip file via `rsync` into ~/hugo
  * Ssh into production server (matabit.org)
  * Unzip public.zip into /var/www/matabit-blog
  * Change /var/www/matabit-blog to www-data group and user
  

```bash
#!/bin/bash 
printf "============================\n"
printf "Running hugo to build blog pages \n"
printf "============================\n"
hugo 
echo
printf "============================\n"
printf "Blog built \n"
printf "============================\n"
echo
printf "============================\n"
printf "Deploying to EC2 instance\n"
printf "============================\n"
echo
zip -r public.zip public/ 
rsync -azP public.zip ubuntu@matabit.org:/home/ubuntu/hugo/
echo
ssh ubuntu@matabit.org << EOF
  sudo unzip -o hugo/public.zip -d /var/www/matabit-blog
  sudo chown -hR www-data:www-data /var/www/matabit-blog
EOF
echo
printf "============================\n"
printf "Blog has been deployed\n" 
printf "============================\n"
echo
```

## Manual method
There are multiple ways to deploy the blog manually. One way is to follow the deploy script rather than running it, you will
get the same result. Given the requirements we are not allowed to clone the repo into the EC2 instance, instead we should transfer the respective files over. Extract the file into the respective webroot. 

To get started: 
  * Build the hugo site using the `hugo` command in the project directory
  * Zip or Tar the public/ directory. In this case I will zip the directory using `zip -r public.zip public`
  * Transfer the zip file to the EC2. You may use rsync, SCP, SFTP. In this example we will use rsync `rsync -azP public.zip ubuntu@matabit.org:/home/ubuntu/hugo/` This will transfer the local public.zip file into the Home directory of the Ubuntu user into a Hugo folder.
  * SSH into the EC2 using `ssh ubuntu@matabit.org`
  * Unzip/Decompress public zip file into Nginx webroot. `sudo -o unzip hugo/public -d /var/www/matabit-blog` Sudo is required becaue we are writing the the /var/www directory. The -o flag specifies to overwrite files. The -d flag specifies the destination. 
  * It's good practice to change the group and user to www-data for webfiles. When we used sudo the permissions we set to only the root user/group. Change the ownership using `sudo chown -hR www-data:www-data /var/www/matabit-blog`
  * Blog is now deployed! Of course you can swap out commands, it all up to the deployer.
