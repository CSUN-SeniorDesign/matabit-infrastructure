# AWS Elastic Container Registry

## What is it?

Elastic Container Registry stores container images, which can be identified by tags that are assigned to them.

## How did we implement it?

```Bash
resource "aws_ecr_repository" "matabit-ecr" {
  name = "matabit-ecr"
}
```

Yes... That is it. That's all that's needed to configure the ECR.

We just need to establish the repository.

If we want to push to it using docker, we have to use the following command.

```
docker push 485876055632.dkr.ecr.us-west-2.amazonaws.com/matabit-ecr:<tag>
```

The unique identifiers are the account ID and the region as well as the repository name.