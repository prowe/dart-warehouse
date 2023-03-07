#!/bin/bash

set -e

stack_info=$(aws cloudformation describe-stacks --stack-name=prowe-dart-warehouse --query='Stacks[0].Outputs')
secret_id=$(echo $stack_info | jq '.[] | select(.OutputKey == "DatabaseSecretArn") | .OutputValue' --raw-output)
export creds=$(aws secretsmanager get-secret-value \
    --secret-id $secret_id \
    --output=text --query='SecretString')
export DBT_HOST=$(echo $stack_info | jq '.[] | select(.OutputKey == "DatabaseAddress") | .OutputValue' --raw-output)
export DBT_USER=$(echo $creds | jq .username --raw-output)
export DBT_PASSWORD=$(echo $creds | jq .password --raw-output) 

docker run -it \
    -v "$(pwd):/usr/app/dbt" \
    -e AWS_DEFAULT_REGION=us-east-1 \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY \
    -e AWS_SESSION_TOKEN \
    -e DBT_HOST \
    -e DBT_USER \
    -e DBT_PASSWORD \
    -e DBT_PROFILES_DIR=/usr/app/dbt \
    --entrypoint=bash \
    ghcr.io/dbt-labs/dbt-postgres "$@"