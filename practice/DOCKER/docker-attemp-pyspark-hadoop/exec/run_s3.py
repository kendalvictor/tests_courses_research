# coding=utf-8
import run

if __name__ == '__main__':

    params = run.get_parse_params()    
    params['job_sh'] = 'job.sh'
    print params
    job_id = run.lunch_job(params=params)    
    job_status = run.get_job_status(job_id) 
    job_log_name = run.get_job_log_name(job_id) 
    print(job_id)
    print(job_status)
    print(job_log_name)