# coding=utf-8

from datetime import datetime, timedelta
import time
import boto3
import sys
import json
import os
import subprocess
import botocore.session

batch = boto3.client('batch')
cloudwatch = boto3.client('logs')

logGroupName = '/aws/batch/job'

def get_job_status(job_id):
    describeJobsResponse = batch.describe_jobs(jobs=[job_id])
    try:
        status = describeJobsResponse['jobs'][0]['status']    
    except IndexError as e:
        status = None

    return status

def get_job_log_name(job_id):
    describe = batch.describe_jobs(jobs=[job_id])
    try:
        stream_name = describe['jobs'][0].get('container', {}).get('logStreamName', '')
    except IndexError as e:
        stream_name = None
    return stream_name

def parse_params(allowed_names=None):
    
    params = sys.argv

    if allowed_names:

        try:
            name = params[1]
        except IndexError:
            names = ','.join(name for name in allowed_names)
            print('Parametro faltante. Debe tener un nombre de la siguiente lista (' + names + ').')
            exit(1)

        if name not in allowed_names:
            print('Nombre de tabla incorrecto. Debe ser un nombre de la siguiente lista (%s' % ', '.join(allowed_names) + ').')
            exit(1)

        # date
        try:
            _date = params[2]
            print(_date)
        except IndexError:
            _date = (datetime.today() - timedelta(days=1)).strftime('%Y-%m-%d')
            print('No se especifica fecha, por defecto ' + str(_date) + '.')

        try:
            datetime.strptime(_date, '%Y-%m-%d')
        except ValueError:
            print('Formato de fecha incorrecto. Debe ser YYYY-MM-DD')
            exit(1)

        # environment
        try:
            env = params[3]
        except IndexError:
            print('No se especifica entorno, por defecto dev.')
            env = 'dev'

        _parms = dict()
        _parms.update({'name': name})
        _parms.update({'date': _date})
        _parms.update({'environment': env})

    else:
        
        try:
            _date = params[1]
            print(_date)
        except IndexError:
            _date = (datetime.today() - timedelta(days=1)).strftime('%Y-%m-%d')
            print('No se especifica fecha, por defecto ' + str(_date) + '.')

        try:
            datetime.strptime(_date, '%Y-%m-%d')
        except ValueError:
            print('Formato de fecha incorrecto. Debe ser YYYY-MM-DD')
            exit(1)

        # environment
        try:
            env = params[2]
        except IndexError:
            print('No se especifica entorno, por defecto dev.')
            env = 'dev'

        _parms = dict()
        _parms.update({'date': _date})
        _parms.update({'environment': env})

    return _parms

def get_parse_params():
        
    allowed_names = ['buyer_segment', 'analytics', 'network_device_analytics', 'network_advertiser_frequency_recency', 'line_item']

    _params = parse_params(allowed_names)
    _params['project_name'] = 'charbeat'

    return _params


#Funcion que devuelve la traza del log
#ejm:
#jobId = 'a48cdfd1-cad4-4823-9920-8e2aabca54a2'    
#formatted_log(jobId)
def formatted_log(job_id):

    startTime=0

    logStreamName = get_job_log_name(job_id=job_id)
        
    return printLogs(logGroupName, logStreamName, startTime)

def printLogs(logGroupName, logStreamName, startTime):
    
    kwargs = {'logGroupName': logGroupName,
              'logStreamName': logStreamName,
              'startTime': startTime,
              'startFromHead': True}

    lastTimestamp = 0L

    while True:
        logEvents = cloudwatch.get_log_events(**kwargs)

        for event in logEvents['events']:
            lastTimestamp = event['timestamp']
            timestamp = datetime.utcfromtimestamp(lastTimestamp / 1000.0).isoformat()
            print '[%s] %s' % ((timestamp + ".000")[:23] + 'Z', event['message'])

        nextToken = logEvents['nextForwardToken']
        if nextToken and kwargs.get('nextToken') != nextToken:
            kwargs['nextToken'] = nextToken
        else:
            break
    return lastTimestamp


def get_complete_log(logGroupName, logStreamName):
    
    nextForwardToken = None

    while True:
        param_group =  " --log-group-name '" + logGroupName + "'"
        param_stream = " --log-stream-name '" + logStreamName + "'"
        param_token = (" --next-token '" + nextForwardToken + "'") if nextForwardToken else ""

        params = param_group + param_stream + param_token
    
        cmd = "aws logs get-log-events" + params
        
        log = open("logs/tmp.log", 'a')
        log.flush()

        p = subprocess.Popen(cmd, shell=True,stdin=subprocess.PIPE, stdout=log, stderr=subprocess.STDOUT)
        (stdoutdata, stderrdata) = p.communicate()
        print stdoutdata
        
        with open('logs/tmp.log','r') as f:        
            lines = f.read().splitlines()
            last_line = lines[-2]            
            last_line = last_line.strip().replace('"','').replace(' ','').split(':')
            last_line_ = lines[-3].strip().replace('"','').replace(' ','')            
            
        nextForwardToken = last_line[1]

        if last_line_ == "events:[],":    
            break

#Funcion que envia a cola de batch un trabajo
#ejm:
#jobId = lunch_job()
#jobId = lunch_job({'name':'analytics','project_name':'nombreproyecto','environment':'dev','date':'2019-01-12'})
#jobId = lunch_job({'name':'analytics','project_name':'nombreproyecto','environment':'prod'})    
def lunch_job(params={}):    

    print "\n"
    session = botocore.session.get_session()

    AWS_ACCESS_KEY_ID = session.get_credentials().access_key
    AWS_SECRET_ACCESS_KEY = session.get_credentials().secret_key
    AWS_DEFAULT_REGION = session.get_config_variable('region')
        
    #entorno
    environment = params.get('environment','dev')
    print environment

    #nombre del proyecto
    project_name = params.get('project_name','project_name').replace('-','')

    #nombre de la marca que se ejecuta
    name = params.get('name',project_name) 

    #bash que va a ejecutar el trabajo
    job_sh = params.get('job_sh','job.sh')

    #fecha
    _date = (datetime.today() - timedelta(days=1)).strftime('%Y-%m-%d')
    _date = params.get('date',_date)
    print _date

    #nombre del trabajo
    job_name = 'job_' + name +  '_' + _date.replace('-','') if _date else 'job_' + name
    print job_name
        
    #cola de trabajo
    job_queue = 'jobs_queue_' + project_name + '_' + environment    
    print job_queue

    #definicion de trabajo
    job_definition = 'job_def_' + project_name + '_' + environment 
    version = get_latest_job_definition(job_definition)['revision']
    job_definition_version = job_definition + ':' + str(version)
    print job_definition_version

    response = batch.submit_job(
        jobName=job_name,
        jobQueue=job_queue,
        jobDefinition=job_definition_version,
        containerOverrides={
            'command': ['/' + job_sh, name, _date],
            'environment': [
                {'name': 'ENV', 'value': environment},
                {'name': 'AWS_ACCESS_KEY_ID', 'value': AWS_ACCESS_KEY_ID},
                {'name': 'AWS_SECRET_ACCESS_KEY', 'value': AWS_SECRET_ACCESS_KEY},
                {'name': 'AWS_DEFAULT_REGION', 'value': AWS_DEFAULT_REGION},
                {'name': 'STACK', 'value': project_name.upper()}
            ]
        }
    )

    return response['jobId']


#funcion para obtener la ultima definicion de trabajo activa
# get_latest_job_definition('job_def_xalokpage_dev')['revision']
def get_latest_job_definition(job_definition_name):
        
    client = boto3.client('batch')

    response = client.describe_job_definitions(jobDefinitionName=job_definition_name,status='ACTIVE')
    

    job_definitions = response.get('jobDefinitions', [])
        
    while(response.get('nextToken') is not None):
        response = client.describe_job_definitions(jobDefinitionName=job_definition_name,
                                                   status='ACTIVE',
                                                   nextToken=response['nextToken'])
        job_definitions.extend(response.get('jobDefinitions', []))

    sorted_definitions = sorted(job_definitions, key=lambda job: job['revision'])

    try:
        return sorted_definitions.pop()    
    except IndexError:
        raise NoActiveJobDefinitionRevision(job_definition=job_definition_name) 


if __name__ == "__main__":
    get_complete_log("/aws/batch/job","job_def_xalokpage_prod/default/b475ee00-ff6e-4a92-a6ea-2b466da6e0f8")