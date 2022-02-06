#!/bin/bash
# Bring in environment including ${ROOT_DIR} etc.
source ../../spark/docker/spark_version
source ../../spark/docker/setup.sh
if [ ! -d tpch-spark/lib ]; then
  mkdir tpch-spark/lib
fi
if [ ! -d tpch-spark/build ]; then
  mkdir tpch-spark/build
fi
SPARK_JAR_DIR="../../spark/build/spark-${SPARK_VERSION}/jars/"
if [ ! -d $SPARK_JAR_DIR ]; then
  echo "Please build spark ($SPARK_JAR_DIR) before building tpch"
  exit 1
fi
cp $SPARK_JAR_DIR/*spark*.jar tpch-spark/lib

S3JAR=../../pushdown-datasource/pushdown-datasource/target/scala-2.12/pushdown-datasource_2.12-0.1.0.jar
if [ ! -f $S3JAR ]; then
  echo "Please build pushdown-datasource ($S3JAR) before building tpch-spark"
  exit 1
fi
cp $S3JAR tpch-spark/lib

MACROSJAR=../../spark/build/downloads/spark-sql-macros_2.12.10_0.1.0-SNAPSHOT.jar
if [ ! -f $MACROSJAR ]; then
  echo "spark-sql-macros jar missing. Please build spark before building tpch-spark"
  exit 1
fi
cp $MACROSJAR tpch-spark/lib

if [ "$1" == "-d" ]; then
  shift
  docker run --rm -it --name tpch_build_debug \
    --mount type=bind,source="$(pwd)"/../tpch,target=/tpch \
    -v "${ROOT_DIR}/build/.m2:${DOCKER_HOME_DIR}/.m2" \
    -v "${ROOT_DIR}/build/.gnupg:${DOCKER_HOME_DIR}/.gnupg" \
    -v "${ROOT_DIR}/build/.sbt:${DOCKER_HOME_DIR}/.sbt" \
    -v "${ROOT_DIR}/build/.cache:${DOCKER_HOME_DIR}/.cache" \
    -v "${ROOT_DIR}/build/.ivy2:${DOCKER_HOME_DIR}/.ivy2" \
    -u "${USER_ID}" \
    --entrypoint /bin/bash -w /tpch/tpch-spark \
    spark-build-${USER_NAME}
else
  docker run --rm -it --name tpch_build \
    --mount type=bind,source="$(pwd)"/../tpch,target=/tpch \
    -v "${ROOT_DIR}/build/.m2:${DOCKER_HOME_DIR}/.m2" \
    -v "${ROOT_DIR}/build/.gnupg:${DOCKER_HOME_DIR}/.gnupg" \
    -v "${ROOT_DIR}/build/.sbt:${DOCKER_HOME_DIR}/.sbt" \
    -v "${ROOT_DIR}/build/.cache:${DOCKER_HOME_DIR}/.cache" \
    -v "${ROOT_DIR}/build/.ivy2:${DOCKER_HOME_DIR}/.ivy2" \
    -u "${USER_ID}" \
    --entrypoint /tpch/scripts/build.sh \
    spark-build-${USER_NAME}
  fi
