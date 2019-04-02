#!/bin/bash

echo "Starting docker, this will take around 30 seconds"
ls $HADOOP_HOME/etc/hadoop/conf/
 
if [ -z ${AWS_ACCESS_KEY_ID+x} ] || [ -z ${AWS_SECRET_ACCESS_KEY+x} ] ; then
  echo 
else 
  HDFS_SITE="
    <configuration>
      <property> 
        <name>dfs.block.size</name> 
        <value>2000000</value> 
        <description>Block size</description> 
      </property>
      <property>
        <name>fs.s3a.access.key</name>
        <value>$AWS_ACCESS_KEY_ID</value>
      </property>
      <property>
        <name>fs.s3a.secret.key</name>
        <value>$AWS_SECRET_ACCESS_KEY</value>
      </property>      
    </configuration>  
  "
  echo "$HDFS_SITE" > $HADOOP_CONF_DIR/hdfs-site.xml
fi

echo "Setting up metastore"

cd /data/hive
ls /data/hive/
ls $HIVE_HOME/bin/
$HIVE_HOME/bin/schematool -dbType derby -initSchema 

cd
$HIVE_HOME/hcatalog/sbin/hcat_server.sh start 
$SPARK_HOME/sbin/start-thriftserver.sh --master "local[4]" --conf "spark.sql.shuffle.partitions=4" 
sleep 20

