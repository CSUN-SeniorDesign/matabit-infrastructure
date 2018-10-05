# How to write into an S3 bucket with CircleCI
This will guide you on how to write into an S3 bucket.

Prerequisites:
  - AWS User
    - Must have API Access keys
    - Must have permission for the S3 bucket

## Set API key variables
On CircleCI, click the settings cog on the respective project and repo. On the left menu, select `AWS Permissions`. From here enter the Access Key ID and Secret Access Key.

## Example of a deploy job
View the setup docs to understand the build process. 
```YML
  deploy-staging:
    docker:
      - image: cibuilds/hugo:latest
    working_directory: /hugo
    environment:
      HUGO_BUILD_DIR: /hugo/public
    steps:
      - run: 
          name: Install aws cli and dependencies
          # Install AWS CLI
          command : |
            apk update && apk add git python python-dev py-pip build-base
            pip install awscli 
      - checkout
      - run: git submodule sync && git submodule update --init
      - run: HUGO_ENV=production hugo -v -d $HUGO_BUILD_DIR
      - run: ls -la $HUGO_BUILD_DIR
      # Deploy using aws-cli into S3 bucket
      - deploy:
          name: deploy to AWS
          command: |
            if [ "${CIRCLE_BRANCH}" = "master" ]; then
              tar -zcvf /hugo/${CIRCLE_SHA1}.tar.gz -C $HUGO_BUILD_DIR .
              aws s3 cp /hugo/${CIRCLE_SHA1}.tar.gz \
              $STAGING_BUCKET${CIRCLE_SHA1}.tar.gz
            else
              echo "Not master branch, dry run only"
            fi
```
