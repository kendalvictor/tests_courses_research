#nativos
from dateutil.relativedelta import relativedelta
from datetime import datetime
import random as rn
import argparse
import glob
import json
import joblib
import os
import gc
import sys

#calculo
import pandas as pd
import numpy as np
import scipy

#terceros
import pip

package_names = ['swifter']
pip.main(['install'] + package_names) 
import swifter
print("load swifter satisfactoriamente")

SEED = 29082013
os.environ['PYTHONHASHSEED'] = str(SEED)
np.random.seed(SEED)
rn.seed(SEED)


import os

BASE_DIR = '/opt/ml/processing/input/'
print(BASE_DIR)

if BASE_DIR not in sys.path: 
    print("LO AGREGO")
    sys.path.append(BASE_DIR)
print(sys.path)

from utils.utils import *

if __name__=='__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--sufijo", type=str)
    args, _ = parser.parse_known_args()

    sufijo = args.sufijo
    target = sufijo.split('clasif')[0][:-1]
    print("sufijo: ", sufijo)
    print("target: ", target)
    print("dicc_seleccionadas: ", dicc_seleccionadas.keys())
    
    seleccionadas = ['cod_sbs_val', target] + dicc_seleccionadas.get(sufijo, [])
    print(seleccionadas)
    print(len(seleccionadas))
    
    seguimiento = pd.read_csv(path_container_input + '/seguimiento.csv', dtype={'cod_sbs_val': str})
    validation = pd.read_csv(path_container_input + '/validation.csv', dtype={'cod_sbs_val': str})
    
    cols_id = ['cod_sbs_val', 'periodo', target] 
    print(cols_id)
    print(len(cols_id))
    
    cols_str = list(set(
        [col for col in list(seguimiento.select_dtypes(include=[object, bool]).columns) + list(validation.select_dtypes(include=[object, bool]).columns) if col not in cols_id]
    ))
    print("Nro categorias: ", len(cols_str))
    col_convert_num = [col for col in cols_str if 'monto' in col.lower() or 'saldo' in col.lower() or 'sow' in col.lower() or 'over' in col.lower() or 'col' in col.lower()]
    for col in col_convert_num:
        print("/"*25, col)
        seguimiento[col] = seguimiento[col].swifter.apply(convert_num)
        validation[col] = validation[col].swifter.apply(convert_num)
    
    
    ### ARTIFICIO SUPONIENDO SE TENDRIA COMO MAXIMO 6 MESES ENTRE VALIDACION Y SEGUIMIENTO
    a = None
    b = None
    c = None
    d = None
    e = None
    f = None
    
    
    for mes in sorted(validation['periodo'].astype(int).unique()):
        if a is None:
            print("a ", mes)
            a = validation[validation['periodo'].astype(int) == mes]
        elif b is None:
            print("b ", mes)
            b = validation[validation['periodo'].astype(int) == mes]
        elif c is None:
            print("c ", mes)
            c = validation[validation['periodo'].astype(int) == mes]   
        elif d is None:
            print("d ", mes)
            d = validation[validation['periodo'].astype(int) == mes]   
        elif e is None:
            print("e ", mes)
            e = validation[validation['periodo'].astype(int) == mes]   
        elif f is None:
            print("f ", mes)
            f = validation[validation['periodo'].astype(int) == mes]   
            
    for mes in sorted(seguimiento['periodo'].astype(int).unique()):
        if a is None:
            print("a ", mes)
            a = seguimiento[seguimiento['periodo'].astype(int) == mes]
        elif b is None:
            print("b ", mes)
            b = seguimiento[seguimiento['periodo'].astype(int) == mes]
        elif c is None:
            print("c ", mes)
            c = seguimiento[seguimiento['periodo'].astype(int) == mes]   
        elif d is None:
            print("d ", mes)
            d = seguimiento[seguimiento['periodo'].astype(int) == mes]   
        elif e is None:
            print("e ", mes)
            e = seguimiento[seguimiento['periodo'].astype(int) == mes]   
        elif f is None:
            print("f ", mes)
            f = seguimiento[seguimiento['periodo'].astype(int) == mes]   
            
        if a is not None:
            print("a ", a.shape)
        if b is not None:
            print("b ", b.shape)
        if c is not None:
            print("c ", c.shape) 
        if d is not None:
            print("d ", d.shape) 
        if e is not None:
            print("e ", e.shape)
        if f is not None:
            print("f ", f.shape)  
    
    del seguimiento
    del validation
    gc.collect()
    
        
    if a is not None:
        mes = list(a['periodo'].unique())[0]
        a[seleccionadas].to_csv('{}/{}_{}.csv'.format(path_container_output, mes, sufijo), index=False)
    if b is not None:
        mes = list(b['periodo'].unique())[0]
        b[seleccionadas].to_csv('{}/{}_{}.csv'.format(path_container_output, mes, sufijo), index=False)
    if c is not None:
        mes = list(c['periodo'].unique())[0]
        c[seleccionadas].to_csv('{}/{}_{}.csv'.format(path_container_output, mes, sufijo), index=False)
    if d is not None:
        mes = list(d['periodo'].unique())[0]
        d[seleccionadas].to_csv('{}/{}_{}.csv'.format(path_container_output, mes, sufijo), index=False)
    if e is not None:
        mes = list(e['periodo'].unique())[0]
        e[seleccionadas].to_csv('{}/{}_{}.csv'.format(path_container_output, mes, sufijo), index=False)
    if f is not None:
        mes = list(f['periodo'].unique())[0]
        f[seleccionadas].to_csv('{}/{}_{}.csv'.format(path_container_output, mes, sufijo), index=False)