Our cluster configuration uses docker host networking. There are a series of scripts to bring up the dockers that make up our cluster.  You will likely need to tailor these scripts to meet the needs of your configuration.

We have several scripts:
spark/docker/start_master_host.sh  This brings up the spark master container using host networking.
spark/docker/start_worker_host.sh  This brings up the spark worker container using host networking. 
spark/docker/start_launcher_host.sh  This brings up the spark launcher container using host networking.  This is the container where our run_tpch.sh will launch the benchmark from. 
dikeHDFS/start_server_host.sh  This brings up the docker with HDFS, and NDP.

There is a config file called spark/spark.config.   It has the config of the addresses and hostnames needed by the above scripts.  You need to modify it for your configuration.  There is an example in our repo.

You also need to configure dikeHDFS/start_server_host.sh with your IP address.  Change the line with --add-host=dikehdfs to include your storage server's ip address.

As an example, in our configuration we typically will follow this sequence.
1)	From our master node we will run start_master_host.sh  and start_launcher_host.sh
2)	Next we go to the worker nodes and run start_worker_host.sh 1 8
3)	Note that the 1 8 above is the number of workers followed by the number of cores to use.
4)	Launch the NDP server via dikeHDFS/start_server_host.sh


