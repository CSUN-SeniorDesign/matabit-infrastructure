import boto3 
from pprint import pprint
client = boto3.client('ecs')


response = client.update_service(
    cluster='matabit-cluster',
    service='matabit-staging-service',
    desiredCount=2,
    taskDefinition='matabit-staging',
    deploymentConfiguration={
        'maximumPercent': 200,
        'minimumHealthyPercent': 100
    },
    networkConfiguration={
        'awsvpcConfiguration': {
            'subnets': [
                'subnet-02624f50b35667231',
                'subnet-0b6c65eb2ef718899',
                'subnet-096c64fec64552e7e'
            ],
            'securityGroups': [
                'sg-0f696eef4489fc778',
            ],
            'assignPublicIp': 'ENABLED'
        }
    },
    platformVersion='LATEST',
    forceNewDeployment=True,
    healthCheckGracePeriodSeconds=60
)