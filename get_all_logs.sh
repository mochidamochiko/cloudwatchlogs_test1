#!/bin/bash

# initialize
LOG_GROUP_NAME="CloudTrail/DefaultLogGroup"
LOG_STREAM_NAME="467412751807_CloudTrail_ap-northeast-1_2"
LOGFILE=trailevent2.log
NEXTTOKENFILE=next.token

# common function
logging() {
  timestamp=`date '+%Y/%m/%d %H:%M:%S'`
  echo "[${timestamp}]: $1"
}

# 一番最初から全件取得する場合はこうする
logging "CloudWatchLogs first entry check..."
result=`aws logs get-log-events --log-group-name ${LOG_GROUP_NAME} --log-stream-name ${LOG_STREAM_NAME} --start-from-head --limit 1 | jq .`

# 後は遡及しまくる
while true
do
  # token logging
  NEXT_TOKEN=`echo $result | jq -r .nextForwardToken`
  echo ${NEXT_TOKEN} > ${NEXTTOKENFILE}

  # log check
  len=`echo $result | jq .events | jq length`

  logging "result ${len} logs"
  if [ ${len} -ne 0 ]; then
    for i in $( seq 0 $(($len - 1)) ); do
      echo $result | jq -r .events[$i].message | jq '"\(.eventTime) \(.eventName)"' >> ${LOGFILE}
    done
  fi

  # get log with next-token
  logging "check next entries..."
  result=`aws logs get-log-events --log-group-name ${LOG_GROUP_NAME} --log-stream-name ${LOG_STREAM_NAME} --next-token ${NEXT_TOKEN} | jq .`
done
