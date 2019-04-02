#!/bin/sh -x
set -e

# PSQL connector
#wget -q https://jdbc.postgresql.org/download/postgresql-42.1.4.jar
#sudo cp postgresql-42.1.4.jar /usr/lib/spark/jars/

#chown -R root /mnt/charbeat

#mkdir -p /mnt/charbeat/analytics2

mkdir -p /tmp/charbeat
mkdir -p /tmp/charbeat/analytics
mkdir -p /tmp/charbeat/buyer_segment
mkdir -p /tmp/charbeat/line_item
mkdir -p /tmp/charbeat/network_advertiser_frequency_recency
mkdir -p /tmp/charbeat/network_device_analytics


# Directorios en filesystem
mkdir -p /mnt
mkdir -p /mnt/charbeat
mkdir -p /mnt/charbeat/analytics
mkdir -p /mnt/charbeat/buyer_segment
mkdir -p /mnt/charbeat/line_item
mkdir -p /mnt/charbeat/network_advertiser_frequency_recency
mkdir -p /mnt/charbeat/network_device_analytics


# Directorios en hadoop
#hdfs dfs -mkdir -p /mnt
#hdfs dfs -mkdir -p /mnt/charbeat
#hdfs dfs -mkdir -p /mnt/charbeat/analytics
#hdfs dfs -mkdir -p /mnt/charbeat/buyer_segment
#hdfs dfs -mkdir -p /mnt/charbeat/line_item
#hdfs dfs -mkdir -p /mnt/charbeat/network_advertiser_frequency_recency
#hdfs dfs -mkdir -p /mnt/charbeat/network_device_analytics


# Directorio de proyectos
export APP_BASE_PATH=/mnt
cd $APP_BASE_PATH

if [ $ENVIRONMENT = "production" ]
then

cat >> /mnt/$PROJECT_NAME/config.json << EOF
{
  "charbeat": {
    "username": "soporte.charbeat@ec.pe",
    "password": "Comercio21+&"
  },
  "storage": {
    "filesystem_path": "/mnt/tmp/charbeat"
  },
  "s3": {
    "bucket": "charbeat-ec",
    "files_bucket": "charbeat-files-ec"
  },
  "hadoop": {
    "main": "/mnt/charbeat"
  },
  "psql": {
    "host": "signwall01.clz6pendayku.us-east-1.rds.amazonaws.com",
    "dbname": "charbeatdb",
    "dbschema": "public",
    "user": "teamsignwall",
    "password": "G4galXDa4Y9i9f"
  }
}
EOF

elif [ $ENVIRONMENT = "development" ]
then

cat >> /mnt/$PROJECT_NAME/config.json << EOF
{
  "charbeat": {
    "username": "soporte.charbeat@ec.pe",
    "password": "Comercio21+&"
  },
  "storage": {
    "filesystem_path": "/tmp/charbeat/"
  },
  "s3": {
    "bucket": "charbeat-dev-ec",
    "files_bucket":"charbeat-dev-files-ec"
  },
  "hadoop": {
    "main": "/mnt/charbeat"
  },
  "psql": {
    "host": "dev01serviciosdb.clz6pendayku.us-east-1.rds.amazonaws.com",
    "dbname": "pushdevdb",
    "dbschema": "public",
    "user": "pushdev",
    "password": "eThu7lohref5ne"
  }
}
EOF

else

# Archivo de configuracion
cat >> /mnt/$PROJECT_NAME/config.json << EOF
{

}
EOF

fi

cat /mnt/$PROJECT_NAME/config.json
chmod 600 /mnt/$PROJECT_NAME/config.json
ls /mnt/$PROJECT_NAME/
pwd

echo $ENVIRONMENT

# wget https://s3.amazonaws.com/$BUCKET/$ENVIRONMENT/$PROJECT_NAME.tar
# tar xvf $PROJECT_NAME.tar
# rm $PROJECT_NAME.tar