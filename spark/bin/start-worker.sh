#!/bin/bash
./sbin/start-worker.sh spark://sparkmaster:7077 > /opt/volume/logs/worker.log 2>&1 &
# --properties-file /conf/spark-defaults.conf
echo "SPARK_WORKER_READY"
echo "SPARK_WORKER_READY" > /opt/volume/status/SPARK_WORKER_STATE

echo "RUNNING_MODE $RUNNING_MODE"

if [ "$RUNNING_MODE" = "daemon" ]; then
    sleep infinity
fi
