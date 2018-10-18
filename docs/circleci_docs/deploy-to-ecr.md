# How To Create Docker Images With CircleCI

Prerequisites:
  - AWS User
    - Must have API Access keys
    - Must have permission for the S3 bucket

## Set API key variables
On CircleCI, click the settings cog on the respective project and repo. On the left menu, select `AWS Permissions`. From here enter the Access Key ID and Secret Access Key.

## Example of a Deploy Job

```YML
  deploy-staging:
    docker:
      - image: ssalehian/circleci-aws-docker:latest
    working_directory: /hugo
    environment:
      HUGO_BUILD_DIR: /hugo/public
      BUILD_ENV: staging
    steps:
      - checkout
      - setup_remote_docker
      - run: git submodule sync && git submodule update --init
      - run: HUGO_ENV=production hugo -v -d $HUGO_BUILD_DIR
      - run: ls -la $HUGO_BUILD_DIR
      - run: ls -la /hugo
      - deploy:
          name: Create Docker Image and push to ECR
          command: |
            $(aws ecr get-login --no-include-email --region us-west-2) 
            docker build -t matabit-blog-staging --build-arg BUILD_VAR=$BUILD_ENV .
            docker tag matabit-blog-staging:latest ****************.dkr.ecr.us-west-2.amazonaws.com/matabit-ecr:staging
            docker push ****************.dkr.ecr.us-west-2.amazonaws.com/matabit-ecr:staging
            touch ${CIRCLE_SHA1}.txt
            aws s3 cp ${CIRCLE_SHA1}.txt $DOCKER_BUCKET_STAGING${CIRCLE_SHA1}.txt
```
We are still building the public folder for hugo first, as we did before.

`- setup_remote_docker` solves the problem of creating a docker image within a docker image and has to be included in order for this to work.

`$(aws ecr get-login --no-include-email --region us-west-2)` authenticates the docker client to the registry so that it has the permission to push to the ECR.

We are pushing a text file with the Commit SHA to an S3 Bucket so that the Lambda function can read the bucket and execute.

To build the correct image we are using the command line argument `--build-arg` for docker so that we can pass the environment variable for the job to the Dockerfile that is being used. `BUILD_VAR=$BUILD_ENV` allows for this.