#!/bin/bash

if [ ! -d build ]; then
  mkdir build
  mkdir conf | true
fi

# Include the setup for our cached local directories. (.m2, .ivy2, etc)
source docker/setup.sh

if [[ "$1" == "-d" ]]; then
  echo "Starting build docker. $1"
  echo "run sbt to build"
  DOCKER_NAME="spark_build_debug"
  shift

  docker run --rm -it --name $DOCKER_NAME \
    --network dike-net \
    --mount type=bind,source="$(pwd)"/spark,target=/spark \
    --mount type=bind,source="$(pwd)"/build,target=/build \
    --mount type=bind,source="$(pwd)"/examples,target=/examples \
    --mount type=bind,source="$(pwd)"/scripts,target=/scripts \
    --entrypoint /bin/bash -w /spark \
  -v "${ROOT_DIR}/build/.m2:${DOCKER_HOME_DIR}/.m2" \
  -v "${ROOT_DIR}/build/.gnupg:${DOCKER_HOME_DIR}/.gnupg" \
  -v "${ROOT_DIR}/build/.sbt:${DOCKER_HOME_DIR}/.sbt" \
  -v "${ROOT_DIR}/build/.cache:${DOCKER_HOME_DIR}/.cache" \
  -v "${ROOT_DIR}/build/.ivy2:${DOCKER_HOME_DIR}/.ivy2" \
  -u "${USER_ID}" \
  "v${DIKE_VERSION}-spark-build-${USER_NAME}" $@
else
  echo "Starting build for $@"
  cd docker
  ./build.sh
  cd ..

  docker run --rm -it --name spark_build \
    --mount type=bind,source="$(pwd)"/spark,target=/spark \
    --mount type=bind,source="$(pwd)"/build,target=/build \
    --mount type=bind,source="$(pwd)"/examples,target=/examples \
    --mount type=bind,source="$(pwd)"/scripts,target=/scripts \
  -v "${ROOT_DIR}/build/.m2:${DOCKER_HOME_DIR}/.m2" \
  -v "${ROOT_DIR}/build/.gnupg:${DOCKER_HOME_DIR}/.gnupg" \
  -v "${ROOT_DIR}/build/.sbt:${DOCKER_HOME_DIR}/.sbt" \
  -v "${ROOT_DIR}/build/.cache:${DOCKER_HOME_DIR}/.cache" \
  -v "${ROOT_DIR}/build/.ivy2:${DOCKER_HOME_DIR}/.ivy2" \
  -u "${USER_ID}" \
  "v${DIKE_VERSION}-spark-build-${USER_NAME}" /scripts/build.sh spark
fi
