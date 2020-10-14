#!/bin/bash

docker run -it --rm  \
-v "$(pwd)/dike-test/s3/SelectObjectContent":/usr/src/mymaven \
-w /usr/src/mymaven \
-v "$(pwd)/build/root/.m2":/root/.m2 \
--network dike-net \
-e "CLASSPATH=/usr/src/mymaven/target/SelectObjectContent-uber.jar" \
-e "AWS_ACCESS_KEY_ID=admin" \
-e "AWS_SECRET_ACCESS_KEY=admin123" \
-p 8000:8000 \
maven:3.6.3-jdk-8 java -Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=y -Xmx1g org.dike.s3.SelectObjectContent 'tpch-test' 'lineitem.csv' \
'SELECT s.l_orderkey,s.l_partkey,s.l_suppkey,s.l_linenumber,s.l_quantity,s.l_extendedprice,s.l_discount,s.l_tax,s.l_returnflag,s.l_linestatus,s.l_shipdate,s.l_commitdate,s.l_receiptdate,s.l_shipinstruct,s.l_shipmode,s.l_comment FROM (SELECT * FROM S3Object LIMIT 4 OFFSET 5000000) s' 
