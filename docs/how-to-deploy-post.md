# How to deploy a blog post to production

## Requirements:
 * Hugo
 * SSH access to EC2 Production server
 * zip and unzip installed on both dev and production
 * Do not use git clone and preferably not git pull

## Easymode
I've created a bash script to easily deploy new blog posts into production. I will also add documentation for the manual method.
First in the matabit-blog repo. Allow the execution of the `deploy.sh` script by running `chmod +x deploy.sh`. Now watch the magic
as the blog post builds and deploys into production. Below are the contents of the bash script. 

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
