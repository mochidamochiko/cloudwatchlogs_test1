#!/bin/bash

# initialize
LOG_GROUP_NAME="CloudTrail/DefaultLogGroup"
LOG_STREAM_NAME="467412751807_CloudTrail_ap-northeast-1"
LOGFILE=trailevent.log
NEXTTOKENFILE=next.token

# get log
echo check `date`
result=`aws logs get-log-events --log-group-name ${LOG_GROUP_NAME} --log-stream-name ${LOG_STREAM_NAME} | jq .`

while true
do
  # token logging
  NEXT_TOKEN=`echo $result | jq -r .nextForwardToken`
  echo ${NEXT_TOKEN} > ${NEXTTOKENFILE}

  # log check
  cat /dev/null > ${LOGFILE}
  len=`echo $result | jq .events | jq length`

  echo result ${len} logs
  if [ ${len} -ne 0 ]; then
    for i in $( seq 0 $(($len - 1)) ); do
      echo $result | jq -r .events[$i].message | jq '"\(.eventTime) \(.eventName)"' >> ${LOGFILE}
    done

    # notification
    echo send notify `date`
    ./notification.sh file://./${LOGFILE}

  fi

  # wait
  sleep 60

  # get log with next-token
  echo check `date`
  result=`aws logs get-log-events --log-group-name ${LOG_GROUP_NAME} --log-stream-name ${LOG_STREAM_NAME} --next-token ${NEXT_TOKEN} | jq .`
done
