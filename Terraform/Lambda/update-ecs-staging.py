import boto3
from pprint import pprint
client = boto3.client('ecs')


def main(event, context):
    response = client.update_service(
        cluster='matabit-cluster',
        service='matabit-staging-service',
        desiredCount=2,
        taskDefinition='matabit-staging',
        deploymentConfiguration={
            'maximumPercent': 200,
            'minimumHealthyPercent': 100
        },
        platformVersion='LATEST',
        forceNewDeployment=True,
        healthCheckGracePeriodSeconds=60
    )
