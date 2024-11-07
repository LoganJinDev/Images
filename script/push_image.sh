#!/bin/bash

# 等待时间 设置默认值
: "${SLEEP_TIME:=1}"
: "${TIME_OUT:=300}"
TOTAL_WAIT=0

while [ ! -f "$LOCAL_IMAGE" ] && [ $TOTAL_WAIT -lt $TIME_OUT ]; do
    echo "Wait for the $LOCAL_IMAGE file to be generated..."
    sleep $SLEEP_TIME
    TOTAL_WAIT=$((TOTAL_WAIT + SLEEP_TIME))
done

if [ -f "$LOCAL_IMAGE" ]; then
    if [ -n "$LOCAL_IMAGE" ] && [ -n "$REMOTE_IMAGE" ]; then
        # 检查 skopeo 命令是否存在
        if command -v skopeo >/dev/null 2>&1 || which skopeo >/dev/null 2>&1; then
            echo "The skopeo copy command starts..."
            skopeo copy docker-archive:$LOCAL_IMAGE docker://$REMOTE_IMAGE --tls-verify=false
        else
            echo "The skopeo command is not installed. Install skopeo and try again."
        fi
    else
        echo "No environment variable is set for LOCAL_IMAGE or REMOTE_IMAGE."
    fi
else
    echo "After waiting for ${TIME_OUT} seconds, no $LOCAL_IMAGE file is generated. Exit the program."
fi