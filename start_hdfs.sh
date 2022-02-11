#! /bin/bash

pushd dikeHDFS
./start_server.sh || (echo "*** failed start of hadoop $?" ; exit 1)

echo "Waiting for hadoop to start..."
sleep 30
echo "Disabling safe mode."
docker exec -it dikehdfs bin/hdfs dfsadmin -safemode leave
popd

if [ ! -d data/tpch-test ]; then
  echo "Initialize tpch database."
  ./init_tpch.sh || (echo "*** failed int of tpch $?" ; exit 1)
fi
docker exec -it dikehdfs bin/hdfs dfs -ls /tpch-test-csv
CMDSTATUS=$?
echo $CMDSTATUS
if [ $CMDSTATUS -ne 0 ]; then
  pushd benchmark/tpch
  echo "Initialize tpch CSV database in hdfs"
  ./run_tpch.sh --local --mode initCsv --protocol hdfs || (echo "*** failed tpch init of CSV for hdfs $?" ; exit 1)
  popd
fi

