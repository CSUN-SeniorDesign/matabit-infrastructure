import boto3 
from pprint import pprint
client = boto3.client('ecs')


response = client.update_service(
    cluster='anthony-test',
    service='anthony-service',
    desiredCount=1,
    taskDefinition='anthony-task-test',
    deploymentConfiguration={
        'maximumPercent': 200,
        'minimumHealthyPercent': 100
    },
    networkConfiguration={
        'awsvpcConfiguration': {
            'subnets': [
                'subnet-0fb75c1b6051a2462',
            ],
            'securityGroups': [
                'sg-0669b8083b6346e37',
            ],
            'assignPublicIp': 'ENABLED'
        }
    },
    platformVersion='LATEST',
    forceNewDeployment=True,
    healthCheckGracePeriodSeconds=60
)