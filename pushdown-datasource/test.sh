#!/bin/bash

echo "Starting S3 and hdfs servers"
pushd ../dikeCS
./start.sh
popd
pushd ../dikeHDFS
../dikeHDFS/start_server.sh
# Wait for hdfs to start before we disable safe mode.
# this allows writes to hdfs within the 20 seconds after starting.
echo "Waiting for hadoop to start..."
sleep 30
echo "Disabling safe mode."
docker exec -it dikehdfs bin/hdfs dfsadmin -safemode leave
popd

echo "Starting pushdown-datasource test"
# Bring in environment including ${ROOT_DIR} etc.
source ../spark/docker/setup.sh

echo "testing pushdown-datasource"
docker run --rm -it --name pushdown_datasource_build \
  --network dike-net \
  --mount type=bind,source="$(pwd)"/../pushdown-datasource,target=/pushdown-datasource \
  -v "${ROOT_DIR}/build/.m2:${DOCKER_HOME_DIR}/.m2" \
  -v "${ROOT_DIR}/build/.gnupg:${DOCKER_HOME_DIR}/.gnupg" \
  -v "${ROOT_DIR}/build/.sbt:${DOCKER_HOME_DIR}/.sbt" \
  -v "${ROOT_DIR}/build/.cache:${DOCKER_HOME_DIR}/.cache" \
  -v "${ROOT_DIR}/build/.ivy2:${DOCKER_HOME_DIR}/.ivy2" \
  -u "${USER_ID}" \
  --entrypoint /pushdown-datasource/scripts/test.sh -w /pushdown-datasource/pushdown-datasource \
  spark-build-${USER_NAME}

echo "Stopping S3 and hdfs servers"
pushd ../dikeHDFS
./stop_server.sh
popd
