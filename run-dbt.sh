#!/bin/bash

set -e

export creds=$(aws secretsmanager get-secret-value \
    --secret-id 'arn:aws:secretsmanager:us-east-1:144406111952:secret:rds!cluster-4f192915-bea1-421a-b447-70c70710b59b-6Zqh1y' \
    --output=text --query='SecretString')
export DBT_HOST=''
export DBT_USER=$(echo $creds | jq .username --raw-output)
export DBT_PASSWORD=$(echo $creds | jq .password --raw-output) 

docker run -it \
    -v "$(pwd):/usr/app/dbt" \
    -e AWS_DEFAULT_REGION=us-east-1 \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY \
    -e AWS_SESSION_TOKEN \
    -e DBT_USER \
    -e DBT_PASSWORD \
    -e DBT_PROFILES_DIR=/usr/app/dbt \
    ghcr.io/dbt-labs/dbt-postgres "$@"