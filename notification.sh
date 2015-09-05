#!/bin/bash
source ./private_sns.conf
aws sns publish --topic-arn ${TOPIC_ARN} --message "$1"
