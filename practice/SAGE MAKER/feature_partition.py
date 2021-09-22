
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


package_names = ['swifter', 'scorecardpy']
pip.main(['install'] + package_names) 
import swifter
import scorecardpy as sc
print("load swifter y scorecardpy satisfactoriamente")

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

    #parser = argparse.ArgumentParser()
    #parser.add_argument("--ultimo_mes", type=str)
    #args, _ = parser.parse_known_args()

    #ultimo_mes = args.ultimo_mes

    #print("Parametro recibido: ultimo_mes ", ultimo_mes)
    print("I")
    data = pd.read_parquet(path_container_universo)
    print(data.shape)
    
    print("/"*25, "TIPADO E IPUTACION")
    cols_target = [targets[7]]  ###------------------------------------- OJO solo se toma 1 target
    for col in cols_target:
        print("/"*25, col)
        data[col] = data[col].swifter.apply(convert_num)
        print(pd.crosstab(data[col], data['periodo']))
        
    print(cols_target)
    print(len(cols_target))
    
    cols_id = ['cod_sbs_val', 'periodo'] + cols_target
    print(cols_id)
    print(len(cols_id))
    
    cols_num = [col for col in data.describe().T.index if col not in cols_id]
    print(len(cols_num))
    cols_str = [col for col in list(data.select_dtypes(include=[object, bool]).columns) if col not in cols_id]
    print(len(cols_str))
    
    ### PARSEADO STR TO FLOAT
    col_convert_num = [
        col for col in cols_str if not('_val' in col.lower() or '_cd' in col.lower())
    ]
    for col in col_convert_num:
        print("/"*25, col)
        data[col] = data[col].swifter.apply(convert_num)
        
    cols_num = [col for col in data.describe().T.index if col not in cols_id]
    print("columnsas numéricas detectadas")
    print(len(cols_num))
    cols_str = [col for col in list(data.select_dtypes(include=[object, bool]).columns) if col not in cols_id]
    print("columnsas categoricas detectadas", cols_str)
    print(len(cols_str))
    
    #####################################################################################  -------------- IMPUTADO
    nulls = data.isnull().sum()
    cols_nulls = nulls[nulls > 0].index
    print("columnas con nulos: ", cols_nulls)

    for col in cols_nulls:
        if col in cols_num:
            data[col] = data[col].fillna(0)
            print("num: ", col)

        elif col in cols_str:
            data[col] = data[col].fillna('DESCONOCIDO')
            print("cat: ", col)
        
    gc.collect()
    print("/"*25, "TRATAMIENTO DE CATEGORICOS")
    print(data['periodo'].astype(str).min(), data['periodo'].astype(str).max())
    
    #####################################################################################  -------------- IMPUTADO
    for col in cols_str:
        if col in data.columns:
            size = data[col].unique().shape[0]
            print(col, size)

            if size == 1:
                del data[col]

            elif size == 2:
                data = pd.get_dummies(data, columns=[col], drop_first=True)

            elif size <= 9:
                data[col + '_cat'] = data[col].copy()    #-- se rescata para que haiga una version en targetecoder y otra onehotencoding
                data = pd.get_dummies(data, columns=[col], drop_first=False)
    
    cols_str = [col for col in data.describe(include=[object, bool]).T.index if col not in cols_id]
    print(len(cols_str))
           
    #####################################################################################  -------------- MESES A PARTICIONAR
    print("/"*25, "PARTICIONAMIENTO")
    
    periodos = [str(_) for _ in sorted([int(periodo) for periodo in data['periodo'].unique()])]
    periodo_train = periodos[:-6]
    periodo_valid = periodos[-6:-4]     ############# CAMBIO AHORA VALIDACION DE DOS MESES
    periodo_seguimiento = periodos[-4:]
    data['periodo'] = data['periodo'].astype(str)
    print(periodos)
    print("periodo_train: ", periodo_train)
    print("periodo_valid: ", periodo_valid)
    print("periodo_seguimiento: ", periodo_seguimiento)     
    
    #####################################################################################  ------------- TRAIN / VALIDATION / SEGUIMIENTO    
    train = data[data['periodo'].astype(str).isin(periodo_train)]
    validation = data[data['periodo'].astype(str).isin(periodo_valid)]
    seguimiento = data[data['periodo'].astype(str).isin(periodo_seguimiento)]
    del data
    gc.collect()
    
    print("train: ", train.shape, train['periodo'].unique())
    print("validation: ", validation.shape, validation['periodo'].unique())
    print("seguimiento: ", seguimiento.shape, seguimiento['periodo'].unique())
    
    ##################################################################################### --------------  TARGET ENCODER 
    
    print("/"*25, "TARGET ENCODER CATEGORICOS TRAIN")
    for col_cat in cols_str:
        print(col_cat)
        _dict = get_encoders_for_targets(train, col_cat=col_cat, cols_target=cols_target)
        
        with open('{}/encoder_target_{}.json'.format(path_container_output, col_cat.lower()), 'w+') as outfile_names:
            json.dump(_dict, outfile_names)
                 
    for col_cat in cols_str:
        with open('{}/encoder_target_{}.json'.format(path_container_output, col_cat.lower()), 'r') as name_file:
            _dict = json.load(name_file)
            print(col_cat)
            
            for target in cols_target:
                name = col_cat + '_encoder_' + target.replace('TARGET_TRADING', '')
                train[name] = train[col_cat].swifter.apply(lambda _: _dict[target].get(_, 0))
                validation[name] = validation[col_cat].swifter.apply(lambda _: _dict[target].get(_, 0))
                seguimiento[name] = seguimiento[col_cat].swifter.apply(lambda _: _dict[target].get(_, 0))
                print(name, end=' ')
        
        #train = pd.get_dummies(train, dummy_na=False, columns=[col_cat], drop_first=False)
        #validation = pd.get_dummies(validation, dummy_na=False, columns=[col_cat], drop_first=False)
        #seguimiento = pd.get_dummies(seguimiento, dummy_na=False, columns=[col_cat], drop_first=False)
        del train[col_cat]
        del validation[col_cat]
        del seguimiento[col_cat]
    
    #####################################################################################
    #--------------------------- identificacion de tipo de clasificacion
    gc.collect()
    clasif = 'normal'
    print("."*25, clasif)
    
    target = cols_target[0]
    print("="*25, target)
    
    use_cols = [target] + [col for col in train.columns if col in validation.columns and col in seguimiento.columns and col not in cols_id]
    spearman = train[use_cols].corr(method='spearman')
    spearman.to_csv('{}/train_correlation_clasif_{}.csv'.format(path_container_output, clasif), index=False)
    
    train[use_cols].to_csv(
        '{}/train_{}_clasif_{}.csv'.format(path_container_output, target.lower(), clasif), 
         index=False
    )
    validation[use_cols].to_csv(
        '{}/validation{}_clasif_{}.csv'.format(path_container_output, target.lower(), clasif), 
        index=False
    )
    
    ##################################################################################### --------------  BALANCEO DEL TARGET
    print("/"*100)
    print(pd.crosstab(train[target], train['periodo']))
    print(pd.crosstab(validation[target], validation['periodo']))
    print("/"*100)
    
    ################# WOE #################
    cortes_dict = {}
    cortes = sc.woebin(
        train[use_cols],
        y=target,
        method='tree',
        no_cores=16,
        count_distr_limit=0.01   ## OJO 0.01 es el valor mínimo , sino lo pone como defecto a 0.05
    )
    for k, v in cortes.items():
        cortes_dict[k] = v.to_dict()
        
    try:
        with open('{}/woe_{}_clasif_{}.json'.format(path_container_output, target.lower(), clasif), 'w+') as outfile_names:
            json.dump(cortes_dict, outfile_names)
    except Exception as e:
        print("ojo: ", str(e))
            
    ################# SELECCION DE VARIABLES #################
    dic_maxprob_corte = {}
    for k, v in cortes.items():
        max_probabilidad_malo = v[v['bin'] != 'missing']['badprob'].max()
        dic_maxprob_corte[k] = [
            max_probabilidad_malo, v['total_iv'].max(), v['woe'].max()
        ]
        
    seleccion_variables = pd.DataFrame(dic_maxprob_corte).T.reset_index()
    seleccion_variables.columns = ['variable', 'max_prob', 'iv', 'woe']
    seleccion_variables = seleccion_variables.sort_values(
        by=['max_prob'], 
        ascending=False
    ).reset_index(drop=True).reset_index().rename(columns={'index': 'ranking_prob'})
    seleccion_variables = seleccion_variables.sort_values(
        by=['iv'], ascending=False
    ).reset_index(drop=True).reset_index().rename(columns={'index': 'ranking_iv'})

    seleccion_variables.to_csv('{}/seleccion_variables_{}_clasif_{}.csv'.format(path_container_output, target.lower(), clasif), index=False)
    
    print("casi")
    train.to_csv('{}/train.csv'.format(path_container_output), index=False)
    validation.to_csv('{}/validation.csv'.format(path_container_output), index=False)
    seguimiento.to_csv('{}/seguimiento.csv'.format(path_container_output), index=False)
    
    del train
    del validation
    del seguimiento

