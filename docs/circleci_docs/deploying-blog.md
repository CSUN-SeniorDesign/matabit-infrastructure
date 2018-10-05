# Deploying to an EC2 instance
Deploying the site requires a fair amount of steps to be completed before an official rollout. For the case of our blog we have a cronjob built into our custom AMI that grabs the latest blog build from the S3 bucket. 

Here's a list of requirements but may change based off configuration:
  - [EC2 IAM Role](https://github.com/CSUN-SeniorDesign/matabit-infrastructure/blob/master/docs/aws_docs/aws-iam-setup.md)
    - GET Object permissions from S3 bucket
  - An S3 Bucket for storing the built blogs
  - [CircleCI](https://github.com/CSUN-SeniorDesign/matabit-infrastructure/blob/master/docs/circleci_docs/deploy-to-s3.md) set to deploy into S3
  - Bash Script to grab and deploy latest blog
  - Cronjob to run the get/deploy script
  - [Custom AMI]() with bash script and cronjob built in (Built with Packer)


## The Bash script
First we must first create a bash script that will grab the latest blog commit hash. We do this via bash. First we store variables we need such s S3 Bucket. Next it's important to export the path in your script. This allows use to run other commands such as `aws s3 ls` in the cronjob. A important command I would like to highlight is `aws s3 ls $BUCKET/staging/ | sort | tail -n 1 | awk '`. This will basically get the latest filename of the build blog. In the script we have functions for staging and master, but are extremely similar only to swap out variables for staging and master. The function first checks to see if the EC2 has the lastest version of the blog stored in the `/tmp/$environment` location. If not, it will download the latest `$LATEST_SHA.tar.gz` from the S3 bucket and save it in the download directory. Next it will check if the `$WEB_DIR` exist, if it does not, create it. After unzip the tar file into the Web directory. After it's unzipped, removed the outdated tar file from the `/tmp/` directory. Next run functions to change the permissions on the `$WEB_DIR` and gracefully restart Nginx. 
```bash
#!/bin/bash

export PATH=${PATH}:/usr/local/bin
# S3 Bucket
BUCKET=s3://matabit-circleci

# Staging variables
STAGING_LATEST=`aws s3 ls $BUCKET/staging/ | sort | tail -n 1 | awk '{print $4}'`
STAGING_FILE_PATH=/tmp/staging/ #Change to /tmp/path
CHECK_STAGING=`ls $STAGING_FILE_PATH`
STAGING_PATH='/var/www/staging/matabit-blog/public/'

# Master variables
MASTER_LATEST=`aws s3 ls $BUCKET/master/ | sort | tail -n 1 | awk '{print $4}'`
MASTER_FILE_PATH=/tmp/master/ #Change to /tmp/path
CHECK_MASTER=`ls $MASTER_FILE_PATH`
MASTER_PATH='/var/www/prod/matabit-blog/public/'

check_staging () {
  if [ "$CHECK_STAGING" != "$STAGING_LATEST" ]; then
    echo "Staging: New update found, deploying now"
    # Get latest tar file
    aws s3 cp $BUCKET/staging/$STAGING_LATEST $STAGING_FILE_PATH/$STAGING_LATEST
    # Unzip into /var/www (For future use) 
    mkdir -p $STAGING_PATH && tar -xzf $STAGING_FILE_PATH/$STAGING_LATEST -C $_
    # Removed outdated tar files
    find $STAGING_FILE_PATH -type f \! -name "*$STAGING_LATEST*" -delete
    # Set web directory permission and gracefully restart nginx
    web_permission
    nginx_graceful_restart
  else
   echo "Staging: No updates found"
  fi
}

check_master() {
if [ "$CHECK_MASTER" != "$MASTER_LATEST" ]; then
    echo "Master: New update found, deploying now"
    # Get latest tar file
    aws s3 cp $BUCKET/master/$MASTER_LATEST $MASTER_FILE_PATH/$MASTER_LATEST
    #Unzip into /var/www (For future use) 
    mkdir -p $MASTER_PATH && tar -xzf $MASTER_FILE_PATH/$MASTER_LATEST -C $_
    # Possibly remove tar file?
    find $MASTER_FILE_PATH -type f \! -name "*$MASTER_LATEST*" -delete
    # Set web directory permission and gracefully restart nginx
    web_permission
    nginx_graceful_restart
  else
    echo "Master: No new updates"
  fi
}

web_permission() {
  chown -hR www-data:www-data /var/www/
}

nginx_graceful_restart() {
  nginx -s reload
}

check_staging
check_master
```

## Adding it to the EC2 Via packer
Next we add this script into the EC2 via packer. You can view the documentation on this [here](). We basically need to add this script to the `/usr/local/bin` directory. Then have a cronjob run every 5 minutes to execute the script: `*/5 * * * *` Make sure this is a sudo cronjob.

## ASG and IAM Role
Make sure the ASG has the correct IAM role policy attached to the EC2. You can view the IAM Role creation [here](https://github.com/CSUN-SeniorDesign/matabit-infrastructure/blob/master/docs/aws_docs/aws-iam-setup.md)

## Where we're at
At this point we should now have an AMI built with the the cronjob running the deployment script every 5 minutes. The ASG handle selecting the custom AMI we've create just for the blog. If CircleCI is set correctly, it should place a newly tar.gz file of the latest blog/commit SHA. The CircleCI triggers on every merge to master. If we decide the deploy to master all we have to do it approve it on CircleCI. The EC2 will detect changes on the S3 bucket via the cronjob/script. The script is fired off to grab and deploy the lastest version of the blog.
