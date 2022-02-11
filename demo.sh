#!/bin/bash


printf "\nNext Test: Spark TPC-H query with HDFS storage and with no pushdown\n"
read -n 1 -s -r -p "Press any key to continue with test."
cd benchmark/tpch
./run_tpch.sh --local -t 6 -ds ndp --protocol ndphdfs
printf "\nTest Complete: Spark TPC-H query with HDFS storage and with no pushdown\n"

printf "\nNext Test: Spark TPC-H query with HDFS storage and with pushdown enabled.\n"
read -n 1 -s -r -p "Press any key to continue with test."
./run_tpch.sh --local -t 6 -ds ndp --protocol ndphdfs --pushdown
printf "\nTest Complete: Spark TPC-H query with HDFS storage and with pushdown enabled.\n"



#printf "\nNext Test: Spark TPC-H query with S3 storage and with no pushdown\n"
#read -n 1 -s -r -p "Press any key to continue with test."
#./run_tpch.sh --local -t 6 -ds ndp --protocol s3
#printf "Test Complete: Spark TPC-H query with S3 storage and with no pushdown\n"

#printf "\nNext Test: Spark TPC-H query with S3 and with pushdown enabled.\n"
#read -n 1 -s -r -p "Press any key to continue with test."
#./run_tpch.sh --local -t 6 -ds ndp --protocol s3 --pushdown
#printf "\nTest Complete: Spark TPC-H query with S3 and with pushdown enabled.\n"
