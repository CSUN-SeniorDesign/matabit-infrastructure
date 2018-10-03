#!/bin/bash

export PATH=${PATH}
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