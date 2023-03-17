#!/bin/bash

set -eo pipefail

STATE_MACHINE=$(aws cloudformation describe-stack-resources \
    --stack-name=prowe-dart-warehouse \
    --logical-resource-id=WarehouseBuildStateMachine \
    --query='StackResources[0].PhysicalResourceId' --output=text)
echo "Found state machine: ${STATE_MACHINE}"

EXECUTION_ID=$(aws stepfunctions start-execution \
    --state-machine-arn=$STATE_MACHINE \
    --query='executionArn' --output=text)
echo "Execution started with id: ${EXECUTION_ID}"

while
    STATUS=$(aws stepfunctions describe-execution \
        --execution-arn=$EXECUTION_ID \
        --query='status' --output=text)
    echo "Execution status: ${STATUS}"
    case $STATUS in
        "SUCCEEDED")
            break
        ;;
        "FAILED" | "TIMED_OUT" | "ABORTED")
            exit 1
        ;;
    esac
do
    sleep 5
done
