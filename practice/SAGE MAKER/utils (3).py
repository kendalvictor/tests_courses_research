import os

import pandas as pd
import numpy as np
try:
    import scorecardpy as sc
except:
    pass


#tabla_universo = 'T_TEST_UNIVERSO_202102'
tabla_universo = 'HM_UNIVERSO_PROPENSION_DESEMBOLSO_BPE'
print("/"*50, "\n")
path_container_input = '/opt/ml/processing/input'
path_container_output = path_container_input.replace('input', 'output')
path_container_utils= path_container_input + '/utils'
path_container_universo = path_container_input + '/' + tabla_universo

print('path_container_input: ', path_container_input)
print('path_container_output: ', path_container_output)
print('path_container_utils: ', path_container_utils)
print('path_container_universo: ', path_container_universo)


def convert_num(val):
    try:
        return float(val)
    except:
        print('|', val, '|')
        return 0.0
    

def get_encoders_for_targets(data, col_cat='CATEGORIA', cols_target=['TARGET']):
    _dict = data.groupby(
        by=[col_cat], 
        as_index=True
    ).agg(
        {target: 'mean' for target in cols_target}
    ).to_dict()
    return _dict


targets = {
    1: 'target_desembolso_f2m_f3m_mayor_10_menor_180',
    2: 'target_desembolso_f2m_f3m_mayor_10_menor_180',
    3: 'target_desembolso_f2m_f3m_mayor_30_menor_180',
    4: 'target_desembolso_f2m_f3m_mayor_30_menor_180',
    5: 'target_desembolso_f2m_mayor_10_menor_180',
    6: 'target_desembolso_f2m_mayor_10_menor_180',
    7: 'target_desembolso_f2m_mayor_30_menor_180',
    8: 'target_desembolso_f2m_mayor_30_menor_180'
}

dicc_bests_models = {
    "target_desembolso_f2m_f3m_mayor_10_menor_180_clasif_normal": 'xgboost-vpc-1-210721-0716-020-7a23f924',
    "target_desembolso_f2m_f3m_mayor_10_menor_180_clasif_all": 'xgboost-vpc-2-210721-0638-007-fee19e51',
    "target_desembolso_f2m_f3m_mayor_30_menor_180_clasif_normal": 'xgboost-vpc-3-210721-0639-020-b16d499d',
    "target_desembolso_f2m_f3m_mayor_30_menor_180_clasif_all": 'xgboost-vpc-4-210721-0718-018-1350508b',
    "target_desembolso_f2m_mayor_10_menor_180_clasif_normal": 'xgboost-vpc-5-210721-0742-019-9e340202',
    "target_desembolso_f2m_mayor_10_menor_180_clasif_all": 'xgboost-vpc-6-210721-1244-003-7c6f4028',
    "target_desembolso_f2m_mayor_30_menor_180_clasif_normal": 'xgboost-vpc-7-210727-1702-011-63804022',  ### NUEVO 2 MESES VALIDATION
    "target_desembolso_f2m_mayor_30_menor_180_clasif_all": 'xgboost-vpc-8-210721-1244-013-f1337622'
}



target_desembolso_f2m_f3m_mayor_10_menor_180_clasif_normal = ['monto_pagado_u6m', 'nro_entidades_ya_no_tiene_saldo_ajustado_u3m', 'ultima_variacion_saldo_ajustado', 'monto_pagado_ult_rcc', 'variacion_neta_saldo_ajustado_u3m', 'monto_adquirido_u6m', 'variacion_neta_saldo_ajustado_u6m', 'entidad_cnt_prom_u9m', 'nro_entidades_termino_prestamo_u9m', 'sum_saldo_ajustado_promedio_u9m', 'tendencia_monto_deuda_agr_ult_mes', 'monto_adquirido_u3m', 'saldo_col_direct_vig_banco_no_ibk', 'saldo_col_direct_vig_competencia', 'nro_bancos_reprogramados_no_ibk', 'cobertura_gar_auto_hipo_pref_over_col_direct_vig']


target_desembolso_f2m_f3m_mayor_10_menor_180_clasif_all = ['monto_pagado_u6m', 'nro_entidades_ya_no_tiene_saldo_ajustado_u3m', 'nro_entidades_ya_no_tiene_saldo_ajustado_u9m', 'ultima_variacion_saldo_ajustado', 'monto_pagado_ult_rcc', 'saldo_col_vig', 'monto_adquirido_u6m', 'variacion_neta_saldo_ajustado_u3m', 'entidad_cnt', 'variacion_neta_saldo_ajustado_u6m', 'tendencia_monto_deuda_agr_ult_mes', 'flg_solo_normal', 'sum_saldo_ajustado_promedio_u9m', 'saldo_col_direct_vig_banco_no_ibk', 'monto_adquirido_u3m', 'nro_entidades_termino_prestamo_u9m', 'saldo_col_direct_vig_competencia', 'flg_tiene_clasif_perdida', 'cobertura_gar_pref_over_col_direct_vig']


target_desembolso_f2m_f3m_mayor_30_menor_180_clasif_normal = ['monto_pagado_u6m', 'nro_entidades_ya_no_tiene_saldo_ajustado_u9m', 'ultima_variacion_saldo_ajustado', 'variacion_neta_saldo_ajustado_u6m', 'variacion_neta_saldo_ajustado_u3m', 'sum_saldo_ajustado_promedio_u9m', 'monto_pagado_ult_rcc', 'saldo_col_direct_vig_competencia', 'monto_adquirido_u6m', 'saldo_col_direct_vig_banco_no_ibk', 'tendencia_monto_deuda_agr_ult_mes', 'nro_entidades_termino_prestamo_u9m', 'nro_bancos_reprogramados_no_ibk', 'entidad_cnt', 'tendencia_monto_deuda_agr_utl_trim', 'monto_adquirido_u3m', 'saldo_col_direct_vig_ibk']


target_desembolso_f2m_f3m_mayor_30_menor_180_clasif_all = ['monto_pagado_u6m', 'nro_entidades_ya_no_tiene_saldo_ajustado_u3m', 'nro_entidades_ya_no_tiene_saldo_ajustado_u9m', 'ultima_variacion_saldo_ajustado', 'monto_pagado_ult_rcc', 'saldo_col_vig', 'monto_adquirido_u6m', 'variacion_neta_saldo_ajustado_u3m', 'entidad_cnt', 'variacion_neta_saldo_ajustado_u6m', 'tendencia_monto_deuda_agr_ult_mes', 'flg_solo_normal', 'sum_saldo_ajustado_promedio_u9m', 'saldo_col_direct_vig_banco_no_ibk', 'monto_adquirido_u3m', 'nro_entidades_termino_prestamo_u9m', 'saldo_col_direct_vig_competencia', 'flg_tiene_clasif_perdida', 'cobertura_gar_pref_over_col_direct_vig']


target_desembolso_f2m_mayor_10_menor_180_clasif_normal = ['monto_pagado_u6m', 'nro_entidades_ya_no_tiene_saldo_ajustado_u3m', 'monto_pagado_u3m',
   'entidad_cnt_prom_u9m', 'nro_entidades_termino_prestamo_u6m',
 'nro_entidades_1_meses_o_mas_con_saldo_ajustado', 'monto_adquirido_u6m', 'nro_entidades_termino_prestamo_u9m', 'sum_saldo_ajustado_promedio_u9m',
  'monto_adquirido_u3m', 'saldo_col_direct_vig_banco_no_ibk',
 'saldo_col_direct_vig_competencia', 'monto_deuda_sf_prom_u9m', 'nro_bancos_reprogramados_no_ibk', 'saldo_col_direct_vig_ibk']  ####### SOLO MONOTONOS


target_desembolso_f2m_mayor_10_menor_180_clasif_all = ['monto_pagado_u6m', 'nro_entidades_ya_no_tiene_saldo_ajustado_u3m', 'nro_entidades_ya_no_tiene_saldo_ajustado_u9m', 'ultima_variacion_saldo_ajustado', 'monto_pagado_ult_rcc', 'variacion_neta_saldo_ajustado_u3m', 'variacion_neta_saldo_ajustado_u6m', 'saldo_col_vig', 'monto_adquirido_u6m', 'entidad_cnt', 'nro_entidades_termino_prestamo_u9m', 'tendencia_monto_deuda_agr_ult_mes', 'sum_saldo_ajustado_promedio_u9m', 'flg_solo_normal', 'saldo_col_direct_vig_banco_no_ibk', 'monto_adquirido_u3m', 'cobertura_gar_auto_hipo_pref_over_col_direct_vig', 'saldo_col_direct_vig_competencia', 'nro_bancos_reprogramados_no_ibk', 'flg_tiene_clasif_perdida']


#target_desembolso_f2m_mayor_30_menor_180_clasif_normal = ['monto_pagado_u6m', 'nro_entidades_ya_no_tiene_saldo_ajustado_u3m',  'sum_saldo_ajustado_promedio_u9m', #'saldo_col_direct_vig_competencia', 'saldo_col_direct_vig_banco_no_ibk', 'nro_entidades_termino_prestamo_u9m', #'monto_adquirido_u6m','nro_bancos_reprogramados_no_ibk', 'entidad_cnt', 
#'segmento_fin_val_S1', 'segmento_fin_val_S2',
#'entidad_cnt_prom_u9m', 'monto_adquirido_u3m', 'saldo_col_direct_vig_ibk', 'nro_bancos_garantias_no_ibk', 'nro_entidades_termino_prestamo_u3m',
#'ultima_variacion_saldo_ajustado',
#'tendencia_monto_deuda_agr_ult_mes', 'tendencia_monto_deuda_agr_utl_trim',
#'monto_pagado_ult_rcc',  'variacion_neta_saldo_ajustado_u6m',
#'variacion_neta_saldo_ajustado_u3m']  #### SOLO MONOTONOS


target_desembolso_f2m_mayor_30_menor_180_clasif_normal = list(set(
[
    'sum_saldo_ajustado_promedio_u9m',
    'monto_adquirido_u6m',
    'monto_deuda_sf_prom_u9m',
    'saldo_col_direct_vig_banco_no_ibk',
    'tendencia_saldo_col_direct_vencido',
    'nro_entidades_termino_prestamo_u9m',
    'ultima_variacion_saldo_ajustado',
    'monto_pagado_u6m',
    'monto_adquirido_u6m',
    'nro_entidades_ya_no_tiene_saldo_ajustado_u3m',
    'entidad_cnt_prom_u9m',
    'percent_promedio_col_direct_ibk_u3m',
    'saldo_col_direct_vig_competencia',
    'tendencia_max_dias_atraso_coloc_directas',
    'saldo_reactiva',
    'nro_entidades_ya_no_tiene_saldo_ajustado_u9m'
]   ##  NUEVAS VARIBABLES
))




target_desembolso_f2m_mayor_30_menor_180_clasif_all = ['monto_pagado_u6m', 'nro_entidades_ya_no_tiene_saldo_ajustado_u9m', 'nro_entidades_ya_no_tiene_saldo_ajustado_u3m', 'ultima_variacion_saldo_ajustado', 'variacion_neta_saldo_ajustado_u3m', 'variacion_neta_saldo_ajustado_u6m', 'monto_pagado_ult_rcc', 'saldo_col_vig', 'monto_deuda_sf_prom_u9m', 'saldo_col_direct_vig_banco_no_ibk', 'saldo_col_direct_vig_competencia', 'monto_adquirido_u6m', 'tendencia_monto_deuda_agr_ult_mes', 'nro_entidades_termino_prestamo_u9m', 'flg_solo_normal', 'nro_bancos_reprogramados_no_ibk', 'tendencia_monto_deuda_agr_utl_trim', 'entidad_cnt', 'monto_adquirido_u3m', 'flg_tiene_clasif_perdida', 'cobertura_gar_pref_over_col_direct_vig']



dicc_seleccionadas = {
    "target_desembolso_f2m_f3m_mayor_10_menor_180_clasif_normal": target_desembolso_f2m_f3m_mayor_10_menor_180_clasif_normal,
    "target_desembolso_f2m_f3m_mayor_10_menor_180_clasif_all": target_desembolso_f2m_f3m_mayor_10_menor_180_clasif_all,
    "target_desembolso_f2m_f3m_mayor_30_menor_180_clasif_normal": target_desembolso_f2m_f3m_mayor_30_menor_180_clasif_normal,
    "target_desembolso_f2m_f3m_mayor_30_menor_180_clasif_all": target_desembolso_f2m_f3m_mayor_30_menor_180_clasif_all,
    "target_desembolso_f2m_mayor_10_menor_180_clasif_normal": target_desembolso_f2m_mayor_10_menor_180_clasif_normal,
    "target_desembolso_f2m_mayor_10_menor_180_clasif_all": target_desembolso_f2m_mayor_10_menor_180_clasif_all,
    "target_desembolso_f2m_mayor_30_menor_180_clasif_normal": target_desembolso_f2m_mayor_30_menor_180_clasif_normal,
    "target_desembolso_f2m_mayor_30_menor_180_clasif_all": target_desembolso_f2m_mayor_30_menor_180_clasif_all
}


def get_cortes_monto_pagado_u6m(val):
    if val < 3000.0:
        return '[-inf,3000.0)'
    elif val < 7000.0:
        return '[3000.0,7000.0)'
    elif val < 32000.0:
        return '[7000.0,32000.0)'
    else:
        return '[32000.0,inf)'

def get_cortes_nro_entidades_ya_no_tiene_saldo_ajustado_u3m(val):
    if val < 1.0:
        return '[-inf,1.0)'
    elif val < 2.0:
        return '[1.0,2.0)'
    else:
        return '[2.0,inf)'

def get_cortes_sum_saldo_ajustado_promedio_u9m(val):
    if val < 10000.0:
        return '[-inf,10000.0)'
    elif val < 35000.0:
        return '[10000.0,35000.0)'
    elif val < 55000.0:
        return '[35000.0,55000.0)'
    elif val < 80000.0:
        return '[55000.0,80000.0)'
    else:
        return '[80000.0,inf)'
    
def get_cortes_saldo_col_direct_vig_competencia(val):
    if val < 10000.0:
        return '[-inf,10000.0)'
    elif val < 410000.0:
        return '[10000.0,410000.0)'
    else:
        return '[410000.0,inf)'

def get_cortes_saldo_col_direct_vig_banco_no_ibk(val):
    if val < 4000.0:
        return '[-inf,4000.0)'
    elif val < 58000.0:
        return '[4000.0,58000.0)'
    elif val < 90000.0:
        return '[58000.0,90000.0)'
    else:
        return '[90000.0,inf)'

def get_cortes_nro_entidades_termino_prestamo_u9m(val):
    if val < 1.0:
        return '[-inf,1.0)'
    elif val < 2.0:
        return '[1.0,2.0)'
    else:
        return '[2.0,inf)'


def get_cortes_monto_adquirido_u6m(val):
    if val < 7000.0:
        return '[-inf,7000.0)'
    elif val < 10000.0:
        return '[7000.0,10000.0)'
    elif val < 26000.0:
        return '[10000.0,26000.0)'
    else:
        return '[26000.0,inf)'



def get_cortes_entidad_cnt_prom_u9m(val):
    if val < 1.0:
        return '[-inf,1.0)'
    elif val < 2.0:
        return '[1.0,2.0)'
    elif val < 3.0:
        return '[2.0,3.0)'
    else:
        return '[3.0,inf)'

def get_cortes_monto_deuda_sf_prom_u9m(val):
    if val < 10000.0:
        return '[-inf,10000.0)'
    elif val < 30000.0:
        return '[10000.0,30000.0)'
    elif val < 40000.0:
        return '[30000.0,40000.0)'
    elif val < 80000.0:
        return '[40000.0,80000.0)'
    else:
        return '[80000.0,inf)'

def get_cortes_tendencia_saldo_col_direct_vencido(val):
    if val < 0.1:
        return '[-inf,0.1)'
    elif val < 0.8:
        return '[0.1,0.8)'
    else:
        return '[0.8,inf)'
    
def get_cortes_ultima_variacion_saldo_ajustado(val):
    if val < -4200.0:
        return '[-inf,-4200.0)'
    elif val < -2000.0:
        return '[-4200.0,-2000.0)'
    elif val < -1000.0:
        return '[-2000.0,-1000.0)'
    elif val < 5200.0:
        return '[-1000.0,5200.0)'
    else:
        return '[5200.0,inf)'

def get_cortes_percent_promedio_col_direct_ibk_u3m(val):
    if val < 0.01:
        return '[-inf,0.01)'
    else:
        return '[0.01,inf)'
    
def get_cortes_tendencia_max_dias_atraso_coloc_directas(val):
    if val < 1.0:
        return '[-inf,1.0)'
    else:
        return '[1.0,inf)'

def get_cortes_saldo_reactiva(val):
    if val < 50000.0:
        return '[-inf,50000.0)'
    elif val < 100000.0:
        return '[50000.0,100000.0)'
    else:
        return '[100000.0,inf)'
    
def get_cortes_nro_entidades_ya_no_tiene_saldo_ajustado_u9m(val):
    if val < 1.0:
        return '[-inf,1.0)'
    elif val < 2.0:
        return '[1.0,2.0)'
    else:
        return '[2.0,inf)'
    
    
dict_orden = {
    "target_desembolso_f2m_f3m_mayor_10_menor_180_clasif_normal": 1,
    "target_desembolso_f2m_f3m_mayor_10_menor_180_clasif_all": 2,
    "target_desembolso_f2m_f3m_mayor_30_menor_180_clasif_normal": 3,
    "target_desembolso_f2m_f3m_mayor_30_menor_180_clasif_all": 4,
    "target_desembolso_f2m_mayor_10_menor_180_clasif_normal": 5,
    "target_desembolso_f2m_mayor_10_menor_180_clasif_all": 6,
    "target_desembolso_f2m_mayor_30_menor_180_clasif_normal": 7,
    "target_desembolso_f2m_mayor_30_menor_180_clasif_all": 8
}
    

dicc_funcion_var = {
    'target_desembolso_f2m_mayor_30_menor_180_clasif_normal': {
        'sum_saldo_ajustado_promedio_u9m': get_cortes_sum_saldo_ajustado_promedio_u9m,
        'monto_adquirido_u6m': get_cortes_monto_adquirido_u6m,
        'monto_deuda_sf_prom_u9m': get_cortes_monto_deuda_sf_prom_u9m,
        'saldo_col_direct_vig_banco_no_ibk': get_cortes_saldo_col_direct_vig_banco_no_ibk,
        'tendencia_saldo_col_direct_vencido': get_cortes_tendencia_saldo_col_direct_vencido,
        'nro_entidades_termino_prestamo_u9m': get_cortes_nro_entidades_termino_prestamo_u9m,
        'ultima_variacion_saldo_ajustado': get_cortes_ultima_variacion_saldo_ajustado,
        'monto_pagado_u6m': get_cortes_monto_pagado_u6m,
        'nro_entidades_ya_no_tiene_saldo_ajustado_u3m': get_cortes_nro_entidades_ya_no_tiene_saldo_ajustado_u3m,
        'entidad_cnt_prom_u9m': get_cortes_entidad_cnt_prom_u9m,
        'percent_promedio_col_direct_ibk_u3m': get_cortes_percent_promedio_col_direct_ibk_u3m,
        'saldo_col_direct_vig_competencia': get_cortes_saldo_col_direct_vig_competencia,
        'tendencia_max_dias_atraso_coloc_directas': get_cortes_tendencia_max_dias_atraso_coloc_directas,
        'saldo_reactiva': get_cortes_saldo_reactiva,
        'nro_entidades_ya_no_tiene_saldo_ajustado_u9m': get_cortes_nro_entidades_ya_no_tiene_saldo_ajustado_u9m
  
    }
}    




