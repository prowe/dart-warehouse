#!/bin/bash

set -e

export creds=$(aws secretsmanager get-secret-value \
    --secret-id 'arn:aws:secretsmanager:us-east-1:144406111952:secret:rds!cluster-cbac33c5-8a5e-4edd-b1b4-6114ef99a0c8-0em0Sr' \
    --output=text --query='SecretString')
export DBT_HOST='prowe-dart-warehouse-rdscluster-qbunkxpbvivf.cluster-c8cpm1j8oloi.us-east-1.rds.amazonaws.com'
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