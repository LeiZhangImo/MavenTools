#!/bin/bash
set -e
# Simple shell script to run a docker container for $RUN_TIME time then grep the docker logs,
# If $INCLUDE is true, the script will return with error when found the $VERIFY_STRING
DOCKER_IMAGE_NAME=$1
DOCKER_RUN_COMMAND=$2
VERIFY_STRING=$3
RUN_TIME=$4
INCLUDE=$5
CONTAINER_NAME=TEMP-$(date +%Y%m%d.%H%M%S)
LOG_FILE=target/${CONTAINER_NAME}.log

# gether the logs
docker run -d --name $CONTAINER_NAME $DOCKER_IMAGE_NAME $DOCKER_RUN_COMMAND
sleep ${RUN_TIME}
docker logs $CONTAINER_NAME > $LOG_FILE

docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME

# get grep result
grep_result=$(cat $LOG_FILE | grep -io -m 1 "${VERIFY_STRING}" || true)
#rm $LOG_FILE

if [ "${INCLUDE}" = "true" ]; then
  if [[ -z "$grep_result" ]]; then
    echo "INCLUDE is ture, can't find \"${VERIFY_STRING}\" in docker logs will return with error"
    exit 1
  fi
elif [ "${INCLUDE}" = "false" ]; then
  echo "INCLUDE is false, found \"${VERIFY_STRING}\" in docker logs will return with error"
  if [[ ! ${#grep_result} -gt 0 ]]; then
    exit 1
  fi
else
  echo "Please set INCLUDE as true or false, \"${INCLUDE}\" is not supported, return error 2"
  exit 2
fi
exit 0
