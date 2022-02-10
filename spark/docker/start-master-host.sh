#!/bin/bash

# Include the setup for our cached local directories. (.m2, .ivy2, etc)
source docker/setup.sh

mkdir -p "${ROOT_DIR}/volume/logs"
rm -f "${ROOT_DIR}/volume/logs/master*.log"

mkdir -p "${ROOT_DIR}/volume/status"
rm -f "${ROOT_DIR}/volume/status/MASTER*"

CMD="${DOCKER_HOME_DIR}/bin/start-master.sh"
RUNNING_MODE="daemon"

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

MASTER_IP="$(cat spark.config | grep MASTER_IP)"
IFS='=' read -a IP_ARRAY <<< "$MASTER_IP"
MASTER_IP=${IP_ARRAY[1]}
echo "MASTER_IP: $MASTER_IP"

if [ $RUNNING_MODE = "interactive" ]; then
  DOCKER_IT="-i -t"
fi

echo "removing work and logs"
rm -rf build/spark-3.1.2/work/
rm -rf build/spark-3.1.2/logs/

#  --cpuset-cpus="9-12" \
DOCKER_RUN="docker run ${DOCKER_IT} --rm \
  -p 4040:4040 -p 6066:6066 -p 7077:7077 -p 8080:8080 -p 5005:5005 -p 18080:18080 \
  --expose 7001 --expose 7002 --expose 7003 --expose 7004 --expose 7005 --expose 7077 --expose 6066 \
  --name sparkmaster \
  --network host $DOCKER_HOSTS \
  -e MASTER=spark://$MASTER_IP:7077 \
  -e SPARK_CONF_DIR=/conf \
  -e SPARK_MASTER_HOST=$MASTER_IP \
  -e SPARK_MASTER_PORT=7077 \
  -e SPARK_PUBLIC_DNS=localhost \
  --mount type=bind,source=$(pwd)/spark,target=/spark \
  --mount type=bind,source=$(pwd)/build,target=/build \
  --mount type=bind,source=$(pwd)/examples,target=/examples \
  --mount type=bind,source=$(pwd)/../dikeHDFS,target=/dikeHDFS \
  --mount type=bind,source=$(pwd)/../benchmark/tpch,target=/tpch \
  --mount type=bind,source=$(pwd)/../pushdown-datasource/pushdown-datasource,target=/pushdown-datasource \
  -v $(pwd)/conf/master:/conf  \
  -v ${ROOT_DIR}/build/.m2:${DOCKER_HOME_DIR}/.m2 \
  -v ${ROOT_DIR}/build/.gnupg:${DOCKER_HOME_DIR}/.gnupg \
  -v ${ROOT_DIR}/build/.sbt:${DOCKER_HOME_DIR}/.sbt \
  -v ${ROOT_DIR}/build/.cache:${DOCKER_HOME_DIR}/.cache \
  -v ${ROOT_DIR}/build/.ivy2:${DOCKER_HOME_DIR}/.ivy2 \
  -v ${ROOT_DIR}/volume/status:/opt/volume/status \
  -v ${ROOT_DIR}/volume/logs:/opt/volume/logs \
  -v ${ROOT_DIR}/bin/:${DOCKER_HOME_DIR}/bin \
  -e "AWS_ACCESS_KEY_ID=${USER_NAME}" \
  -e "AWS_SECRET_ACCESS_KEY=admin123" \
  -e "AWS_EC2_METADATA_DISABLED=true" \
  -e RUNNING_MODE=${RUNNING_MODE} \
  -u ${USER_ID} \
  v${DIKE_VERSION}-spark-run-${USER_NAME} ${CMD}"

if [ $RUNNING_MODE = "interactive" ]; then
  eval "${DOCKER_RUN}"
else
  eval "${DOCKER_RUN}" &
  while [ ! -f "${ROOT_DIR}/volume/status/SPARK_MASTER_STATE" ]; do
    sleep 1
  done

  cat "${ROOT_DIR}/volume/status/SPARK_MASTER_STATE"
fi
