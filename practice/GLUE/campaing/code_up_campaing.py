from datetime import datetime
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql import Row
from collections import OrderedDict
from pyspark.sql.functions import col

args = getResolvedOptions(sys.argv, ['JOB_NAME'])

#sc = SparkContext.getOrCreate()
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args['JOB_NAME'], args)

def convert_to_row(d):
    return Row(
        **OrderedDict(sorted(d.items()))
    )

bucket_name = "aatempjson2"
marca = 'elcomercio'
date_format = '20190301'
campaings = 'mundialista,semanasanta'
events = ['received', 'ctr']

for campain in campaings.split(','):
    # carga de todos los json de la campaña en un solo dataframe
    path_json_spark = 's3://{}/{}/{}/{}/*.json'.format(bucket_name, marca, date_format, campain)
    df_csv = spark.read.json(path_json_spark)
    
    # en la primera iteracion se obtienen los eventos a contar
    #if not events:
    #    events = [_.event for _ in df_csv.select('event').distinct().collect()]
    
    # Se genera el diccionario con el conteo por evento
    dicc_save = {event: df_csv.where(col("event") == event).count() for event in events}
    del df_csv
    
    # Convertimos diccionario a dataframe para su facil manejo
    data = sc.parallelize(
        [dicc_save]
    ).map(convert_to_row).toDF()
    
    # Guardamos lo obtenido en un nuveo s3
    bucket_output = 'aaoutputattempjson2'
    hoy = str(datetime.now()).replace(' ', '-').replace(':', '-').split('.')[0]
    path = '{}/{}.csv'.format(campain, hoy)
    data.write.mode('append').csv('s3://{}/{}'.format(bucket_output, hoy))

job.commit()