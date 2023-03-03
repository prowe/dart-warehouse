#!/bin/bash

set -e

export creds=$(aws redshift-serverless get-credentials --workgroup-name=dart-warehouse-wg)
export DBT_PASSWORD=$(echo $creds | jq .dbPassword --raw-output)
export DBT_USER=$(echo $creds | jq .dbUser --raw-output)

docker run -it \
    -v "$(pwd):/usr/app/dbt" \
    -e AWS_DEFAULT_REGION=us-east-1 \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY \
    -e AWS_SESSION_TOKEN \
    -e DBT_USER \
    -e DBT_PASSWORD \
    -e DBT_PROFILES_DIR=/usr/app/dbt \
    ghcr.io/dbt-labs/dbt-redshift "$@"