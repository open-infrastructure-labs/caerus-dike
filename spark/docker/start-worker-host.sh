#!/bin/bash

source docker/setup.sh

mkdir -p "${ROOT_DIR}/volume/logs"
rm -f "${ROOT_DIR}/volume/logs/worker*.log"

mkdir -p "${ROOT_DIR}/volume/status"
rm -f "${ROOT_DIR}/volume/status/WORKER*"

CMD="${DOCKER_HOME_DIR}/bin/start-worker.sh"
RUNNING_MODE="daemon"

WORKERS=1
if [ "$#" -ge 1 ] ; then
  WORKERS=$1
fi
CORES=4
if [ "$#" -ge 2 ] ; then
  CORES=$2
fi
echo "removing work and logs"
rm -rf build/spark-3.1.2/work/
rm -rf build/spark-3.1.2/logs/

echo "Workers: $WORKERS"
echo "Cores: $CORES"
DOCKER_HOSTS="$(cat spark.config | grep DOCKER_HOSTS)"
IFS='=' read -a IP_ARRAY <<< "$DOCKER_HOSTS"
DOCKER_HOSTS=${IP_ARRAY[1]}
HOSTS=""
IFS=',' read -a IP_ARRAY <<< "$DOCKER_HOSTS"
for i in "${IP_ARRAY[@]}"
do
  HOSTS="$HOSTS --add-host=$i"
done
DOCKER_HOSTS=$HOSTS
echo "Docker Hosts: $DOCKER_HOSTS"

WORKER_IP="$(cat spark.config | grep WORKER_IP)"
IFS='=' read -a IP_ARRAY <<< "$WORKER_IP"
WORKER_IP=${IP_ARRAY[1]}
echo "WORKER_IP: $WORKER_IP"

if [ $RUNNING_MODE = "interactive" ]; then
  DOCKER_IT="-i -t"
fi
#  --cpuset-cpus="16-19" \

DOCKER_RUN="docker run ${DOCKER_IT} --rm -p 8081:8081 \
  --expose 7012 --expose 7013 --expose 7014 --expose 7015 --expose 8881 \
  --name sparkworker $WORKER_CPUS \
  --network host ${DOCKER_HOSTS} \
  -e SPARK_CONF_DIR=/conf \
      -e SPARK_WORKER_INSTANCES=$WORKERS \
      -e SPARK_WORKER_CORES=$CORES \
      -e SPARK_WORKER_MEMORY=8g \
      -e SPARK_WORKER_PORT=8881 \
      -e SPARK_WORKER_IP=$WORKER_IP \
      -e SPARK_WORKER_WEBUI_PORT=8081 \
      -e SPARK_PUBLIC_DNS=localhost \
      -e HDFS_PATH=dikehdfs \
  --mount type=bind,source="$(pwd)"/spark,target=/spark \
  --mount type=bind,source=$(pwd)/build,target=/build \
  -v ${ROOT_DIR}/conf/worker:/conf \
  -v /nvme-part/caerus/rf972-caerus-dike/data:/tpch-data \
  -v ${ROOT_DIR}/build/.m2:${DOCKER_HOME_DIR}/.m2 \
  -v ${ROOT_DIR}/build/.gnupg:${DOCKER_HOME_DIR}/.gnupg \
  -v ${ROOT_DIR}/build/.sbt:${DOCKER_HOME_DIR}/.sbt \
  -v ${ROOT_DIR}/build/.cache:${DOCKER_HOME_DIR}/.cache \
  -v ${ROOT_DIR}/build/.ivy2:${DOCKER_HOME_DIR}/.ivy2 \
  -v ${ROOT_DIR}/volume/status:/opt/volume/status \
  -v ${ROOT_DIR}/volume/logs:/opt/volume/logs \
  -v ${ROOT_DIR}/bin/:${DOCKER_HOME_DIR}/bin \
  -e RUNNING_MODE=${RUNNING_MODE} \
  -u ${USER_ID} \
  v${DIKE_VERSION}-spark-run-${USER_NAME} ${CMD}"


if [ $RUNNING_MODE = "interactive" ]; then
  eval "${DOCKER_RUN}"
else
  eval "${DOCKER_RUN}" &
  while [ ! -f "${ROOT_DIR}/volume/status/SPARK_WORKER_STATE" ]; do
    sleep 1
  done

  cat "${ROOT_DIR}/volume/status/SPARK_WORKER_STATE"
fi

