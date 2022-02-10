#!/bin/bash


if [[ ! -z "${SPARK_MASTER_HOST}" ]]; then
  echo "master ip is: $SPARK_MASTER_HOST"
  ./sbin/start-master.sh --ip $SPARK_MASTER_HOST --port 7077 > /opt/volume/logs/master.log 2>&1 &
else
  bin/spark-class org.apache.spark.deploy.master.Master > /opt/volume/logs/master.log 2>&1 &
fi
# --properties-file /conf/spark-defaults.conf
echo "SPARK_MASTER_READY"
echo "SPARK_MASTER_READY" > /opt/volume/status/SPARK_MASTER_STATE

echo "RUNNING_MODE $RUNNING_MODE"

if [ "$RUNNING_MODE" = "daemon" ]; then
    sleep infinity
fi
