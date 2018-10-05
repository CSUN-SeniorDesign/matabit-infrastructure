# Get Blog From S3 - Script - Cronjob

```YAML
---
  - name: Copy get-s3.sh script to /usr/local/bin
    become: true
    template:
      src: get-s3.sh
      dest: /usr/local/bin/get-blog
      mode: +x
  
  - name: Set crontab to get lastest blog version
    become: true
    cron: 
      minute: "*/5"
      job: "/usr/local/bin/get-blog >/dev/null 2>&1"
```

We are using the `template` module to copy the deployment script over to the AMI and give the execution permissions to all the users.

Additionally, we are setting the script as a crontab, which is running every 5 minutes.