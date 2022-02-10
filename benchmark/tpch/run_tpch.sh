#!/bin/bash

source ../../spark/docker/spark_version
source ../../spark/docker/setup.sh

if [ "$#" -lt 1 ]; then
  echo "Usage: --debug --workers # <args for test or --help>"
  exit 1
fi

LOCAL=NO
DEBUG=NO
DEBUG_EXECUTOR=NO
WORKERS=1
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -w)
    WORKERS="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--debug)
    DEBUG=YES
    shift # past argument
    ;;
    -de|--debug-exec)
    DEBUG_EXECUTOR=YES
    shift # past argument
    ;;
    -l|--local)
    LOCAL=YES
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

echo "DEBUG"  = "${DEBUG}"
echo "WORKERS" = "${WORKERS}"
echo "LOCAL" = "${LOCAL}"
TEST=NO
#set_speed $WORKERS
#DOCKER=sparkmaster
DOCKER=sparklauncher
# --conf "spark.submit.pyFiles=/build/dike.zip" \
if [ ${DEBUG} == "YES" ]; then
  echo "Debugging"
  docker exec -it ${DOCKER} spark-submit --master local \
  --class main.scala.TpchQuery \
  --conf "spark.jars.ivy=/build/ivy" \
  --conf "spark.driver.maxResultSize=20g" \
  --conf "spark.driver.memory=2g" \
  --conf "spark.executor.memory=2g" \
  --conf "spark.driver.extraJavaOptions=-classpath /conf/:/build/spark-${SPARK_VERSION}/jars/*: -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=10.124.48.63:5006" \
  --packages com.github.luben:zstd-jni:1.5.0-4,org.json:json:20210307,javax.json:javax.json-api:1.1.4,org.glassfish:javax.json:1.1.4,com.github.scopt:scopt_2.12:4.0.0-RC2,ch.cern.sparkmeasure:spark-measure_2.12:0.17 \
  --jars /build/downloads/spark-sql-macros_2.12.10_0.1.0-SNAPSHOT.jar,/dikeHDFS/client/ndp-hdfs/target/ndp-hdfs-1.0.jar,/build/extra_jars/*,/pushdown-datasource/target/scala-2.12/pushdown-datasource_2.12-0.1.0.jar,/build/downloads/h2-1.4.200.jar \
  /tpch/tpch-spark/target/scala-2.12/spark-tpc-h-queries_2.12-1.0.jar $@ --workers ${WORKERS}
    #--packages com.github.scopt:scopt_2.12:4.0.0-RC2,com.amazonaws:aws-java-sdk:1.11.853,org.apache.hadoop:hadoop-aws:3.2.0,org.apache.commons:commons-csv:1.8 \
    #  --conf "spark.sql.parquet.enableVectorizedReader=false" \
elif [ ${DEBUG_EXECUTOR} == "YES" ]; then
  echo "Debugging"
  docker exec -it ${DOCKER} spark-submit --master local \
  --class main.scala.TpchQuery \
  --conf "spark.jars.ivy=/build/ivy" \
  --conf "spark.driver.maxResultSize=20g" \
  --conf "spark.driver.memory=2g" \
  --conf "spark.executor.memory=2g" \
  --conf "spark.driver.extraJavaOptions=-classpath /conf/:/build/spark-${SPARK_VERSION}/jars/*:/examples/scala/target/scala-2.12/ -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=172.169.1.10:5005" \
  --packages com.github.luben:zstd-jni:1.5.0-4,org.json:json:20210307,javax.json:javax.json-api:1.1.4,org.glassfish:javax.json:1.1.4,com.github.scopt:scopt_2.12:4.0.0-RC2,ch.cern.sparkmeasure:spark-measure_2.12:0.17 \
  --jars /build/downloads/spark-sql-macros_2.12.10_0.1.0-SNAPSHOT.jar,/dikeHDFS/client/ndp-hdfs/target/ndp-hdfs-1.0.jar,/build/extra_jars/*,/pushdown-datasource/target/scala-2.12/pushdown-datasource_2.12-0.1.0.jar,/build/downloads/h2-1.4.200.jar \
  /tpch/tpch-spark/target/scala-2.12/spark-tpc-h-queries_2.12-1.0.jar $@ --workers ${WORKERS}
elif [ ${LOCAL} == "YES" ]; then
  echo "Local with $WORKERS workers."
  docker exec -it ${DOCKER} spark-submit --master local[$WORKERS] \
  --conf "ivy.shared.default.root=/build/ivy_jars" \
  --conf "spark.jars.ivy=/build/ivy" \
  --conf "spark.driver.maxResultSize=20g" \
  --conf "spark.task.maxDirectResultSize=20g" \
  --conf "spark.sql.broadcastTimeout=10000000" \
  --conf "spark.driver.memory=2g" \
  --conf "spark.executor.memory=2g" \
  --conf "spark.dynamicAllocation.enabled=false" \
  --conf "spark.eventLog.enabled=true" \
  --conf "spark.eventLog.dir=/build/spark-events" \
  --conf "spark.driver.extraJavaOptions=-classpath /conf/:/build/spark-${SPARK_VERSION}/jars/*:/examples/scala/target/scala-2.12/" \
  --packages com.github.luben:zstd-jni:1.5.0-4,org.json:json:20210307,javax.json:javax.json-api:1.1.4,org.glassfish:javax.json:1.1.4,com.github.scopt:scopt_2.12:4.0.0-RC2,ch.cern.sparkmeasure:spark-measure_2.12:0.17 \
  --jars /dikeHDFS/client/ndp-hdfs/target/ndp-hdfs-1.0.jar,/pushdown-datasource/target/scala-2.12/pushdown-datasource_2.12-0.1.0.jar \
  /tpch/tpch-spark/target/scala-2.12/spark-tpc-h-queries_2.12-1.0.jar $@ --workers ${WORKERS}
elif [ ${TEST} != "YES" ]; then
#local[$WORKERS]
#spark://172.18.0.2:7077
#  --conf "spark.executor.instances=1" \
#  --conf "spark.executor.cores=1" \
  HOST=sparkmaster
  HOST=172.169.1.40
  DRIVER_IP=172.169.1.40
  docker exec -it ${DOCKER} spark-submit --total-executor-cores $WORKERS \
              --master spark://$HOST:7077 \
  --conf "ivy.shared.default.root=/build/ivy_jars" \
  --conf "spark.jars.ivy=/build/ivy" \
  --conf "spark.driver.maxResultSize=20g" \
  --conf "spark.task.maxDirectResultSize=20g" \
  --conf "spark.sql.broadcastTimeout=10000000" \
  --conf "spark.driver.memory=2g" \
  --conf "spark.executor.memory=2g" \
  --conf "spark.dynamicAllocation.enabled=false" \
  --conf "spark.eventLog.enabled=true" \
  --conf "spark.eventLog.dir=/build/spark-events" \
  --conf "spark.hadoop.dfs.client.use.datanode.hostname=true" \
  --conf "spark.hadoop.dfs.namenode.rpc-address=172.169.1.60:9000" \
  --conf "spark.driver.host=${DRIVER_IP}" \
  --conf "spark.driver.bindAddress=${DRIVER_IP}" \
  --conf "spark.driver.extraJavaOptions=-classpath /conf/:/build/spark-${SPARK_VERSION}/jars/*:/examples/scala/target/scala-2.12/" \
  --packages com.github.luben:zstd-jni:1.5.0-4,org.json:json:20210307,javax.json:javax.json-api:1.1.4,org.glassfish:javax.json:1.1.4,com.github.scopt:scopt_2.12:4.0.0-RC2,ch.cern.sparkmeasure:spark-measure_2.12:0.17 \
  --jars /dikeHDFS/client/ndp-hdfs/target/ndp-hdfs-1.0.jar,/pushdown-datasource/target/scala-2.12/pushdown-datasource_2.12-0.1.0.jar \
  /tpch/tpch-spark/target/scala-2.12/spark-tpc-h-queries_2.12-1.0.jar $@ --workers ${WORKERS}
fi
# --jars /dikeHDFS/client/ndp-hdfs/target/ndp-hdfs-1.0.jar,/pushdown-datasource/target/scala-2.12/pushdown-datasource_2.12-0.1.0.jar \

#,org.dike.hdfs:ndp-hdfs:1.0 /dikeHDFS/client/ndp-hdfs/target/ndp-hdfs-1.0-jar-with-dependencies.jar,
#--repositories file:/build/dike \
#  --packages com.github.scopt:scopt_2.12:4.0.0-RC2,com.amazonaws:aws-java-sdk:1.11.853,org.apache.hadoop:hadoop-aws:3.2.0,org.apache.commons:commons-csv:1.8 \
#  --conf "spark.files.maxPartitionBytes=16777216" \
#  --conf "spark.sql.files.maxPartitionBytes=16777216" \
#  --conf "spark.sql.shuffle.partitions=1" \
#  --jars /build/extra_jars/*,/pushdown-datasource/target/scala-2.12/pushdown-datasource_2.12-0.1.0.jar,/build/h2-latest.jar \
# --num-executors 1 --executor-cores 1 \


STATUS=$?
if [ $STATUS -eq 0 ];then
  echo "TPCH Successful"
else
  echo "TPCH Failed"
  exit $STATUS
fi
