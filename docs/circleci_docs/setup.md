# Setting up CircleCI
Circle CI is a tool used for Continuous Integration and Continuous Deployment. The CI part will build and test our code why the deploy handles pushing the code into its respective server.

## Initial setup
Make sure CircleCI is set up for your Github repo. Once CircleCI is confirmed to be on your git repo we can create the configuration file. This file is what CircleCI reads to trigger it's job. Create a file in `circleci/config.yml` at the root of your project. Inside the file add the boilerplate:

```YML
version: 2 # Specify CircleCI Version
jobs: # Run Jobs/Pipelines
  build: # Example of a job
    docker: # Use a docker container
    working_directory: # Set working directory environment
    environment: # Another variable
    steps: # Steps used for this job to run
```
Let's populate this config to get a better understanding of what is going on

```YML
version: 2
jobs:
  build:
    docker:
      - image: cibuilds/hugo:latest # Use this docker image for the project
    working_directory: /hugo # Save into this directory
    environment:
      HUGO_BUILD_DIR: /hugo/public # Set this directory as a variable
    steps: # Steps to execute this job
      - run: apk update && apk add git # Update git and install git
      - checkout # Checkout repo
      - run: git submodule sync && git submodule update --init #Install submodule
      - run: HUGO_ENV=production hugo -v -d $HUGO_BUILD_DIR # Run hugo to build the blog
```
This is the basic setup for CircleCI. It will run the build job. This will basically run commands to build the hugo blogs

## Workflow
Workflows are like pipelines that allow the CircleCI config to run based off triggers. It's similar to writing the jobs. You will write this after the specified jobs

```YAML
workflows: # State the workflow
  version: 2 # Use version 2
  build_and_test: # Name of the workflow/pipeline
    jobs: # This refers to the jobs in the config above
      - build # Note how we create a job name build in the config above, you'll bring that here
      - test: # Another job to run after build was successful
          requires:
          - build
      - deploy-staging: # Job to run after test is passed
        requires:
            - test 
      - hold-production: # Hold used to manually approve
          type: approval
          requires:
            - test
      - deploy-master: # Deploy into master when approved
          requires:
            - hold-production
```
