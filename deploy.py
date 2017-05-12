#!/usr/bin/env python

import argparse
import json
import boto3


class DeploymentManager():
    def __init__(self):
        self.client = boto3.client('ecs')
        self.cluster = 'reefsource'

    def get_env_variables_by_env_name(self, environment_name):
        '''
        :param task_family:
        :return:
        returns an array of env variables for given environment, example:
        [
            {
            "name": "MYSQL_ROOT_PASSWORD",
            "value": "password"
            }
        ]
        '''

        s3 = boto3.resource('s3')
        env_vars = s3.Object('secrets.coralreefsource.org', '{environment_name}_environment_vars'.format(environment_name=environment_name))
        json_str = env_vars.get()["Body"].read().decode('utf-8')

        return json.loads(json_str)

    def get_template(self, image_tag, task_family, env_vars):
        return {
            "family": task_family,
            "containerDefinitions": [{
                "name": task_family,
                "image": "078097297037.dkr.ecr.us-east-1.amazonaws.com/{task_family}:{image_tag}".format(task_family=task_family, image_tag=image_tag),
                "memoryReservation": 384,
                "environment": env_vars,
                "entryPoint": ["./image-preprocess-aws.sh"]
            }]
        }

    def register_task_definition(self, template):
        response = self.client.register_task_definition(**template)
        return response['taskDefinition']['revision']

    def deploy(self, image_tag):
        env_vars = self.get_env_variables_by_env_name('image_preprocessor')

        template = self.get_template(image_tag, task_family='image_preprocessor', env_vars=env_vars)
        self.register_task_definition(template)


def get_args():
    parser = argparse.ArgumentParser(description='deploys django app and applies migration using docker image tag')
    parser.add_argument('--image_tag', required=True, help='docker tag')

    args = parser.parse_args()
    return args


if __name__ == '__main__':
    args = get_args()

    deploy_manager = DeploymentManager()
    deploy_manager.deploy(args.image_tag)
