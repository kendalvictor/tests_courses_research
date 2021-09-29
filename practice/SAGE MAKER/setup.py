## nativos
from datetime import datetime
import os
import sys

## terceros
import sagemaker
import boto3

## config
BASE_DIR = os.path.dirname(os.getcwd())
if BASE_DIR not in sys.path: sys.path.append(BASE_DIR)
proyecto = 'propension'
#tabla_universo = 'T_TEST_UNIVERSO_202102'
tabla_universo = 'HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE'
tabla_sow_bpe = 'HM_SOW_BPE'
tabla_sow_be = 'HM_SOW_BE'
esquema_vpc = 'd_mdl_vpc_disc'


from UTILITARIO_CODE.utils import targets, dicc_seleccionadas
normal = [1]
target = targets[7]
print("target ::::::::: ", target)
clasif = 'normal' if len(normal) == 1 else 'all'
sufijo = '{}_clasif_{}'.format(target.lower(), clasif)
seleccionadas = dicc_seleccionadas[sufijo]

## SDF
now = datetime.now()
sess = sagemaker.session.Session()
s3 = boto3.resource('s3')
bucket = sess.default_bucket() 
region = boto3.Session().region_name
smclient = boto3.Session().client('sagemaker')

## path Docker
path_container_input = '/opt/ml/processing/input'
path_container_output = path_container_input.replace('input', 'output')
path_container_utils= path_container_input + '/utils'
path_container_universo = path_container_input + '/' + tabla_universo



## 0 - FEATURE ENGINEERING / ANALISIS
uri_universo_athena = 's3://{}/vpc/{}/athena/{}'.format(bucket, proyecto, tabla_universo)
uri_output = 's3://{}/vpc/{}/output3'.format(bucket, proyecto)
uri_code = 's3://{}/vpc/{}/code'.format(bucket, proyecto)

## utils
path_instancia_util = os.path.join(BASE_DIR, 'DESEMBOLSO_7/UTILITARIO_CODE/utils.py')
prefix_utils = '{}/utils.py'.format(uri_code.split(bucket)[-1][1:])

## 1 - SELECCION DE VARIABLES
select = '{}/seleccion_variables_{}_clasif_{}.csv'.format(uri_output, target.lower(), str(clasif))
woe = '{}/woe_{}_clasif_{}.json'.format(uri_output, target.lower(), clasif)
correlation = '{}/train_correlation_clasif_{}.csv'.format(uri_output, clasif)


## 2 - PREPARACION PRE-MODEL
uri_raw = uri_code.replace('code', 'raw')
uri_raw_sufijo = '{}/{}'.format(uri_raw, sufijo)
uri_split = uri_code.replace('code', 'split')
uri_split_sufijo = '{}/{}'.format(uri_split, sufijo)

uri_train = '{}/train_{}_clasif_{}.csv'.format(uri_output, target.lower(), str(clasif))
uri_valid = '{}/validation.csv'.format(uri_output)
uri_segui = '{}/seguimiento.csv'.format(uri_output)

uri_copy_train_raw = '{}/{}/train.csv'.format(uri_raw, sufijo)
uri_copy_valid_raw = '{}/{}/validation.csv'.format(uri_raw, sufijo)
uri_copy_segui_raw = '{}/{}/seguimiento.csv'.format(uri_raw, sufijo)

## 3 MODEL
uri_models = 's3://{}/vpc/{}/models'.format(bucket, proyecto)
uri_train_xgb = '{}/train.csv'.format(uri_split_sufijo, sufijo)
uri_valid_xgb = '{}/validation.csv'.format(uri_split_sufijo, sufijo)
save_results = 'resuts_{}.csv'.format(sufijo)

## 4 - PRE- PREDICT
uri_segui_folder = uri_code.replace('code', 'seguimiento')
uri_copy_seg = '{}/seguimiento.csv'.format(uri_segui_folder)
uri_copy_val = '{}/validation.csv'.format(uri_segui_folder)
uri_contraste = uri_code.replace('code', 'contraste')

## 5 - INFERENCIA
uri_predict = uri_code.replace('code', 'prediccion')
min_auc = 0.78




## 3 - NUEVO MES

cols_pre_export =  ['periodo', 'cod_sbs_val', 'target_desembolso_f2m_mayor_30_menor_180', 'sow_ibk', 'porc_coloc_direct_vig_cmpt', 'porc_coloc_direct_vig_cajas', 'porc_coloc_direct_vig_no_ibk', 'porc_coloc_direct_vig_bcos', 'sow_otros_bancos', 'porc_coloc_direct_vig_ibk', 'sow_cajas', 'saldo_coloc_direct_vig_cmpt', 'ult_var_saldo_ajustado_amt', 'saldo_coloc_direct_vig_no_ibk', 'saldo_coloc_direct_vig_cajas', 'saldo_reactiva', 'saldo_coloc_indirectas', 'var_neta_saldo_ajustado_u3_amt', 'saldo_fae', 'saldo_coloc_directas', 'saldo_coloc_direct_vig_bcos', 'saldo_coloc_direct_vig_ibk', 'saldo_coloc_direct_tc', 'deuda_sf_prom_ult9m', 'prom_reprog_u12m', 'nro_entid_financ_prom_ult9m_cnt', 'monto_adquirido_u6_amt', 'nro_var_10k_30k_negativa_u6', 'prom_gar_u12m', 'nroregs_reactiva_bcos', 'monto_pagado_u3_amt', 'nro_entidades', 'monto_pagado_ult_rcc_amt', 'tendencia_nro_coloc_direct_bancos_v2', 'prom_fae_u12m', 'nro_var_10k_30k_negativa_u3', 'nroregs_fae_bcos']

cols_export = ['periodo_val', 'cod_sbs_val', 'score_desembolso', 'GRUPO_PROPENSION', 'GRUPO_PROPENSION_FINO', 'target_desembolso_f2m_mayor_30_menor_180', '_categoryc_nroregs_reactiva_bcos', '_categoryc_sow_ibk', '_categoryc_porc_coloc_direct_vig_no_ibk', '_categoryc_sow_cajas', '_categoryc_coloc_direct_vig_bcos', '_categoryc_nroregs_fae_bcos', '_categoryc_coloc_direct_vig_no_ibk', '_categoryc_coloc_direct_vig_competencia', '_categoryc_coloc_direct_vig_cajas', '_categoryc_coloc_direct_vig_ibk', '_categoryc_porc_coloc_direct_vig_cmpt', '_categoryc_porc_coloc_direct_vig_cajas', '_categoryc_porc_coloc_direct_vig_ibk', '_categoryc_sow_otros_bancos', '_categoryc_porc_coloc_direct_vig_bcos', '_range_coloc_indirectas', '_range_reactiva', '_range_coloc_direct_vig_cmpt', '_range_coloc_direct_vig_cajas', '_range_coloc_direct_vig_bcos', '_range_coloc_direct_vig_ibk', '_range_fae', '_range_coloc_directas', '_range_coloc_direct_vig_no_ibk', 'sow_ibk', 'porc_coloc_direct_vig_cmpt', 'porc_coloc_direct_vig_cajas', 'porc_coloc_direct_vig_no_ibk', 'porc_coloc_direct_vig_bcos', 'sow_otros_bancos', 'porc_coloc_direct_vig_ibk', 'sow_cajas', 'saldo_coloc_direct_vig_cmpt', 'ult_var_saldo_ajustado_amt', 'saldo_coloc_direct_vig_no_ibk', 'saldo_coloc_direct_vig_cajas', 'saldo_reactiva', 'saldo_coloc_indirectas', 'var_neta_saldo_ajustado_u3_amt', 'saldo_fae', 'saldo_coloc_directas', 'saldo_coloc_direct_vig_bcos', 'saldo_coloc_direct_vig_ibk', 'saldo_coloc_direct_tc', '_cuartil_saldo_coloc_directas', 'deuda_sf_prom_ult9m', 'prom_reprog_u12m', 'nro_entid_financ_prom_ult9m_cnt', 'monto_adquirido_u6_amt', 'nro_var_10k_30k_negativa_u6', 'prom_gar_u12m', 'nroregs_reactiva_bcos', 'monto_pagado_u3_amt', 'nro_entidades', 'monto_pagado_ult_rcc_amt', 'tendencia_nro_coloc_direct_bancos_v2', 'prom_fae_u12m', 'nro_var_10k_30k_negativa_u3']