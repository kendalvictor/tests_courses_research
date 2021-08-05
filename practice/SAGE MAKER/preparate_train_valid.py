
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
    seleccionadas = dicc_seleccionadas.get(sufijo, [])
    print(len(seleccionadas))
    
    seleccionadas = [target] + seleccionadas
    print("seleccionadas", seleccionadas)
    
    path_container_input = '/opt/ml/processing/input'
    path_container_output = path_container_input.replace('input', 'output')
    print('path_container_input: ', path_container_input)
    print('path_container_output: ', path_container_output)
    
    train = pd.read_csv('{}/train.csv'.format(path_container_input))
    train[seleccionadas].to_csv('{}/train.csv'.format(path_container_output), index=False)
    del train
   
    validation = pd.read_csv('{}/validation.csv'.format(path_container_input))
    
    if 'f3m' in sufijo:
        validation[seleccionadas].to_csv('{}/validation.csv'.format(path_container_output), index=False)
    else:
        print(">> No tiene f3m", end=' ')
        seguimiento = pd.read_csv('{}/seguimiento.csv'.format(path_container_input))
        print(seguimiento.shape, 'periodo' in seguimiento.columns)
        
        periodos = [str(_) for _ in sorted([int(periodo) for periodo in seguimiento['periodo'].unique()])]
        agregado = periodos[0]
        print("agregado: ", agregado, type(agregado))
        seguimiento = seguimiento[seguimiento['periodo'].astype(str) == agregado]
    
        if 'normal' in sufijo:
            print(">> Tiene normal", end=' ')
            seguimiento = seguimiento[seguimiento['flg_solo_normal'].astype(int) == 1]
            print(seguimiento.shape)
            
        validation = pd.concat(
            [
                validation[seleccionadas], 
                seguimiento[seleccionadas]
            ],
            ignore_index=True,
            axis=0
        )
        print("validation: ", validation.shape)
        
        del seguimiento
        validation[seleccionadas].to_csv('{}/validation.csv'.format(path_container_output), index=False)
        
    del validation
   