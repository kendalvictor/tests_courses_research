import platform
import boto3
import pandas as pd

version = int(platform.python_version_tuple()[0])
if version < 3:
    from StringIO import StringIO
else:
    from io import StringIO

BUCKET_NAME_GLUE = 'attemp-glue'
BUCKET_NAME_CSVS = 'charbeat-trafic'
path_work = 'gestion.pe/2018/12/'

s3 = boto3.resource('s3')
bucket_csv = s3.Bucket(BUCKET_NAME_CSVS)

list_df = []
col_analysis = 'page_avg_time'
df_up = pd.DataFrame(columns=['dia', col_analysis])

for obj in bucket_csv.objects.filter(Prefix=path_work):
    key = obj.key
    print(key)
    url_up = 'https://s3.amazonaws.com/{}/{}'.format(BUCKET_NAME_CSVS, key)
    df_s3 = pd.read_csv(url_up, parse_dates=['dia'])[['dia', col_analysis]]
    df_s3['mes'] = df_s3['dia'].dt.month 
    
    csv_buffer = StringIO()
    df_s3.to_csv(csv_buffer, index=False)
    s3.Object(BUCKET_NAME_GLUE, key).put(Body=csv_buffer.getvalue(), ACL='public-read')