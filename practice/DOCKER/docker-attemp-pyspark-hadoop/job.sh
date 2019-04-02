#!/bin/sh -x

export PYTHONIOENCODING=utf8

spark-submit --conf spark.executor.extrajavaoptions="-Xmx1g" --driver-memory 5g --executor-memory 8g /mnt/charbeat/api.py $1 $2