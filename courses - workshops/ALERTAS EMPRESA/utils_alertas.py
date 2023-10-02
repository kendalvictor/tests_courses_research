import pandas as pd
import numpy as np
from datetime import datetime

from sklearn.metrics import roc_auc_score, recall_score, precision_score, f1_score

from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta


## ----------------------------------------------------------------------------------------------------------------------
## ----------------------------------------------------------------------------------------------------------------------
## ----------------------------------------------------------------------------------------------------------------------
## ----------------------------------------------------------------------------------------------------------------------
########################################### CONEXION MARKET ########################################### 

dicc_conection_market = {
    'host': '10.11.12.90\BDT',
    'user': 'ibetlmarket',
    'port': 1433,
    'password': 'm@rk3t2o15',
    'database': 'MARKET'
}


## ----------------------------------------------------------------------------------------------------------------------
## ----------------------------------------------------------------------------------------------------------------------
## ----------------------------------------------------------------------------------------------------------------------
## ----------------------------------------------------------------------------------------------------------------------
########################################### CONFIGURACION DE DISEÑO DE COSECHA ########################################### 

now = datetime.now()
nro_cosechas_previas = 9

ultimo_mes_cerrado =  datetime.strptime((now - relativedelta(months=1)).strftime('%Y-%m'), '%Y-%m').strftime('%Y-%m-%d')
first_analysis_month = datetime.strptime((now - relativedelta(months=nro_cosechas_previas)).strftime('%Y-%m'), '%Y-%m').strftime('%Y-%m-%d')
first_rfm_month = datetime.strptime((now - relativedelta(months=15)).strftime('%Y-%m'), '%Y-%m').strftime('%Y-%m-%d')

rango_general =  [_ for _ in list(pd.date_range(first_analysis_month, ultimo_mes_cerrado, freq='MS'))]
rango_rfm =  [_ for _ in list(pd.date_range(first_rfm_month, ultimo_mes_cerrado, freq='MS'))]

rango_reactiva_int = [int(_.strftime("%Y%m")) for _ in list(pd.date_range(datetime.strptime('202001', '%Y%m'), ultimo_mes_cerrado, freq='MS'))]

tramos = []
for periodo_base in rango_general:
    
    rango_particular = [
        int(_.strftime('%Y%m')) for _ in list(
            pd.date_range((periodo_base - relativedelta(months=11)), (periodo_base + relativedelta(months=2)), freq='MS')
        )
    ]
    
    tramos.append(
        (int(periodo_base.strftime('%Y%m')),             #mes cerrado de la cosecha del mes siguiente
         rango_particular,  # listado 14 periodos sumando dos adelante y restando 11 periodos atras
         rango_particular[-8:-2],
         rango_particular[-5:-2],
         rango_particular[:2],     # 2 meses delante de la coasecha (año previo)
         rango_particular[-2:])    # 2 meses delante de la coasecha (año actual)
    )

tramos = tramos[:-1]
print("EJEMPLO:")
print(
    str(tramos[-1][0]) + ' mes cerrado de la cosecha de ' + str(tramos[-1][1][-3]), tramos[-1][2], tramos[-1][3],
    '\n',  'historia',
    '\n', tramos[-1][1][:-2],  '\n',  '-'*100,  '\n',tramos[-1][-1],  '\n',  '-'*100,  '\n',tramos[-1][-2]
)



tramos_rfm = []
for periodo_base in rango_rfm:
    rango_particular_rfm = [
        int(_.strftime('%Y%m')) for _ in list(
            pd.date_range((periodo_base - relativedelta(months=11)), (periodo_base + relativedelta(months=2)), freq='MS')
        )
    ]
    
    tramos_rfm.append(
        (int(periodo_base.strftime('%Y%m')),             #mes cerrado de la cosecha del mes siguiente
         rango_particular_rfm,  # listado 14 periodos sumando dos adelante y restando 11 periodos atras
         rango_particular_rfm[-8:-2],
         rango_particular_rfm[-5:-2],
         rango_particular_rfm[:2],     # 2 meses delante de la coasecha (año previo)
         rango_particular_rfm[-2:])    # 2 meses delante de la coasecha (año actual)
    )
    
tramos_rfm = tramos_rfm[:-1]
print("EJEMPLO:")
print(
    str(tramos_rfm[0][0]) + ' mes cerrado de la cosecha de ' + str(tramos_rfm[0][1][-3]), tramos_rfm[0][2], tramos_rfm[0][3],
    '\n',  'historia',
    '\n', tramos_rfm[0][1][:-2],  '\n',  '-'*100,  '\n',tramos_rfm[0][-1],  '\n',  '-'*100,  '\n',tramos_rfm[0][-2]
)



def generate_listado_u3m(data, col_name, values='CANT_TRX', index=['COD_UNICO'], columns=['PERIODO'], aggfunc=np.sum, tramos=tramos):
    pivoteo = pd.pivot_table(
        data, 
        values=values, index=index, columns=columns, aggfunc=aggfunc, fill_value=0
    ).unstack().reset_index()
    
    pivoteo.columns = columns + index + [col_name]
    #display(pivoteo.head())
    contador = 1
    dicc = {col_name: list}
    
    for tramo in tramos:
        _3_meses_previos = tramo[1][:-2]
        print(tramo[0], _3_meses_previos)

        _3m_actual = pivoteo[pivoteo['PERIODO'].astype(int).isin(_3_meses_previos)].groupby(by=index).agg(dicc)

        _3m_actual = _3m_actual.reset_index().rename(columns={'index': index[0]})
        _3m_actual['PERIODO'] = tramo[0]

        if contador == 1:
            acum_3 = _3m_actual.copy()
        else:
            acum_3 = pd.concat(
                [acum_3, _3m_actual], axis=0
            )

        print(acum_3.shape, )
        contador +=1
        del _3m_actual
    del pivoteo
    return acum_3

## ----------------------------------------------------------------------------------------------------------------------
## ----------------------------------------------------------------------------------------------------------------------
## ----------------------------------------------------------------------------------------------------------------------
## ----------------------------------------------------------------------------------------------------------------------
########################################### IDENTIFICACION DE LAS BANCAS ########################################### 

cosechas_habilitadas = ['202009', '202010', '202011', '202012', '202101', '202102', '202103']
cosechas_kpi = ['202009', '202010', '202011', '202012', '202101', '202102', '202103', '202104', '202105']
zonal_provincia = ['BEP ZONAL 1', 'BEP ZONAL 2', 'BEP ZONAL 3']
zonal_gran = ['BEL ZONAL 1', 'BEL ZONAL 3']
zonal_mediana = ['BEL ZONAL 2']


def filtro_banca_s1provincia(df, col_funnel='FUNNEL_4', cosechas_a_analizar=cosechas_habilitadas):
    return df[
        (df['PERIODO'].astype(str).isin(cosechas_a_analizar))  &
        (df['ZONAL'].isin(zonal_provincia)) &
        (df['SEGMENTO'].isin(['S1'])) & 
        (df[col_funnel] == 1) 
    ]


def filtro_banca_s2provincia(df, col_funnel='FUNNEL_4', cosechas_a_analizar=cosechas_habilitadas):
    return df[
        (df['PERIODO'].astype(str).isin(cosechas_a_analizar)) &  
        (df['ZONAL'].isin(zonal_provincia)) & 
        (df['SEGMENTO'].isin(['S2'])) &
        (df[col_funnel] == 1) 
    ]

def filtro_banca_gran(df, col_funnel='FUNNEL_4', cosechas_a_analizar=cosechas_habilitadas):
    return df[
        (df['PERIODO'].astype(str).isin(cosechas_a_analizar)) &  
        (df['ZONAL'].isin(zonal_gran))  &   
        (df[col_funnel] == 1) 
    ]

def filtro_banca_mediana(df, col_funnel='FUNNEL_4', cosechas_a_analizar=cosechas_habilitadas):
    return df[
        (df['PERIODO'].astype(str).isin(cosechas_a_analizar)) &  
        (df['ZONAL'].isin(zonal_mediana)) &  
        (df[col_funnel] == 1) 
    ]




## ----------------------------------------------------------------------------------------------------------------------
## ----------------------------------------------------------------------------------------------------------------------
## ----------------------------------------------------------------------------------------------------------------------
## ----------------------------------------------------------------------------------------------------------------------
########################################### CREACION / SELECCION DE VARIABLES ########################################### 
def searhc_no_zero(lista):
    meses = 0
    for val in lista[::-1]:
        if val > 0:
            return meses
        meses += 1
    
    return meses

creation_mode = True
col_target = 'target_FINAL_fusion_atraso_feve_2Mbueno'
target_severo = 'target_FINAL_fusion_atraso_SEGUIDO_15000_FEVE_2Mbueno'

sufijo_nr = '_SIN_SEVERIDAD'


def get_div_means_perios(val_anio_act , val_anio_pas):
    if pd.isnull(val_anio_act) or not val_anio_act:
        return 0
    
    if pd.isnull(val_anio_pas) or not val_anio_pas:
        return val_anio_act
    
    return val_anio_act / val_anio_pas


def add_new_var_x_cut_up(df, colum='', cortes=[], impute=None, up=True, soft=False, reverse=False):
    for cut in cortes:
        new_col = '_{}_cut_{}_{}'.format(cut, 'up' if up else 'down', colum).replace('NRO', 'NUM')
        
        if soft:
            lambda_up = lambda _: None if pd.isnull(_) else(1 if _ > cut else 0)
            lambda_down = lambda _: None if pd.isnull(_) else(1 if _ < cut else 0)
            df[new_col] = df[colum].apply(lambda_up) if up else df[colum].apply(lambda_down)
        else:
            lambda_up = lambda _: None if pd.isnull(_) else(1 if _ >= cut else 0)
            lambda_down = lambda _: None if pd.isnull(_) else(1 if _ <= cut else 0)
            df[new_col] = df[colum].apply(lambda_up) if up else df[colum].apply(lambda_down)
        
        print(">> ", new_col)
        if impute is not None:
            print("Se imputará con: ", impute)
            df[new_col] = df[new_col].fillna(impute)
            
        if reverse:
            print("Se aplicará lógica inversa")
            lambda_inversa = lambda _: None if pd.isnull(_) else int(not(_))
            df[new_col] = df[new_col].fillna(lambda_inversa)    
        
        data_valid = df[df[col_target].notnull()]
        #roc_auc = roc_auc_score(data_valid[new_col], data_valid[col_target]) precision_score
        print("Metricas:::::::::::::::::::::: ",
              ' RECALL: ',  recall_score(data_valid[col_target], data_valid[new_col]),
              ' PRECISION: ',  precision_score(data_valid[col_target], data_valid[new_col]),
              ' F1: ',  f1_score(data_valid[col_target], data_valid[new_col]),
              ' GINI: ', 2*roc_auc_score(data_valid[col_target], data_valid[new_col]) - 1
             )
        
        print("/"*50)
    return df




## ----------------------------------------------------------------------------------------------------------------------
## ----------------------------------------------------------------------------------------------------------------------
## ----------------------------------------------------------------------------------------------------------------------
## ----------------------------------------------------------------------------------------------------------------------
########################################### SEGUIMIENTO KPIS  ###########################################################

def resultado_por_periodo(setalertas, periodo_str, completo=True, col_target=col_target):
    malos = setalertas[
        (setalertas['PERIODO'].astype(int).isin(periodo_str)) & (setalertas[col_target] == 1) & (setalertas[col_target].notnull()) \
        & (setalertas['TIENE_DEUDA_REFINANCIADO_RCC'] == 0) & (setalertas['TIENE_DEUDA_REFINANCIADO_IBK'] == 0)
    ]
    total_malos = len(
        set(malos['COD_UNICO'])
    )
    alertados = setalertas[
            (setalertas['PERIODO'].astype(int).isin(periodo_str)) & (setalertas['FLG_ALERTA']== 1) & (setalertas[col_target].notnull()) \
            & (setalertas['TIENE_DEUDA_REFINANCIADO_RCC'] == 0) & (setalertas['TIENE_DEUDA_REFINANCIADO_IBK'] == 0) 
    ]
    #print(set(alertados['COD_UNICO']))
    
    total_se_alerta = len(set(
        alertados['COD_UNICO'])
    )
    total_cartera = len(
        set(
            setalertas[setalertas['PERIODO'].astype(int).isin(periodo_str)]['COD_UNICO']
        )
    )
    bien_alertados = set(alertados['COD_UNICO']) & set(malos['COD_UNICO']) 
    #print(type(bien_alertados),bien_alertados, "//////////", len(bien_alertados))
    #pd.DataFrame(
    #    list(
    #        set(bien_alertados)
    #    )
    #).to_excel('bien_alertado_meddiana_prueba.xlsx')
    
    #print("malos detectados ", total_malos)
    #print("contactados ", total_se_alerta, end=" ")
    #print("universo meses de evluación :", total_cartera, '  Se contacta a ', round(total_se_alerta*100 / total_cartera, 3), '%')
    #print("RECALL : " , len(bien_alertados), ' --> ', len(bien_alertados) / total_malos if total_malos > 0 else 0)
    #print("EFECTIVIDAD: ", len(bien_alertados) / total_se_alerta)
    
    #print(periodo_str, total_cartera)
    cobertura = len(bien_alertados) / total_malos if total_malos > 0 else 0
    efectividad = len(bien_alertados) / total_se_alerta if total_se_alerta > 0 else 0
    malos_totales = round((total_se_alerta if total_se_alerta > 0 else 0)*100 / total_cartera, 2)
    
    valores = [
        total_cartera, 
        total_se_alerta, 
        str(malos_totales) + ' %', total_malos, 
        len(bien_alertados), str(round(cobertura*100, 2)) + ' %', 
        str(round(efectividad*100, 2)) + ' %'
    ]
    no_completo = [
        total_cartera, total_se_alerta, 
        str(round(total_se_alerta*100 / total_cartera, 2)) + ' %',
        '-',
        '-', 
        '-',
        '-'
    ]
    
    return pd.DataFrame(
        {str(periodo_str): valores if completo else no_completo}, 
        index=['cartera', 'alertados', 'impacto_capacity', 'malos_detectados','acertados', 'cobertura_malos', 'efectividad']
    )



def seguimiento_alerta(setalertas, periodos, num_alertas, col_target=col_target):
    struct = []
    dict_por_alerta = {}
    listado_bien_alertados = [[], []]
    listado_mal_alertados = [[], []]
    
    totales_periodo = set(setalertas[
        (setalertas['PERIODO'].astype(int).isin(periodos))
        & (setalertas['TIENE_DEUDA_REFINANCIADO_RCC'] == 0) & (setalertas['TIENE_DEUDA_REFINANCIADO_IBK'] == 0)
    ]['COD_UNICO'])
    
    ya_vienen_mal = set(setalertas[
        (setalertas['PERIODO'].astype(int).isin(periodos)) & (setalertas[col_target].isnull()) \
        & (setalertas['TIENE_DEUDA_REFINANCIADO_RCC'] == 0) & (setalertas['TIENE_DEUDA_REFINANCIADO_IBK'] == 0)
    ]['COD_UNICO'])
    
    malos = set(setalertas[
        (setalertas['PERIODO'].astype(int).isin(periodos)) & (setalertas[col_target] == 1) & (setalertas[col_target].notnull())\
        & (setalertas['TIENE_DEUDA_REFINANCIADO_RCC'] == 0) & (setalertas['TIENE_DEUDA_REFINANCIADO_IBK'] == 0)
    ]['COD_UNICO'])
    
    severos = set(setalertas[
        (setalertas['PERIODO'].astype(int).isin(periodos)) & (setalertas[target_severo] == 1)
    ]['COD_UNICO'])
    
    
    #print(len(ya_vienen_mal), len(malos))
    
    for i in range(num_alertas):
        con_alerta = 'A' + str(i + 1)
        
        alertados = set(setalertas[
                (setalertas['PERIODO'].astype(int).isin(periodos)) & (setalertas[con_alerta] == 1)  & (setalertas[col_target].notnull())\
                & (setalertas['TIENE_DEUDA_REFINANCIADO_RCC'] == 0) & (setalertas['TIENE_DEUDA_REFINANCIADO_IBK'] == 0) #& \
        ]['COD_UNICO'])
        
        
        alertados_fino = set(setalertas[
                (setalertas['PERIODO'].astype(int).isin(periodos)) & (setalertas[con_alerta] == 1) & (setalertas[col_target] == 1)\
                & (setalertas['TIENE_DEUDA_REFINANCIADO_RCC'] == 0) & (setalertas['TIENE_DEUDA_REFINANCIADO_IBK'] == 0) #& \
        ]['COD_UNICO'])
        
        alertados_severos = severos & alertados
        bien_alertados = malos & alertados
        bien_alertados_severos = malos & alertados & severos
        mal_alertados = alertados - bien_alertados
        
        #listado_alertados_fino =
        
        listado_bien_alertados[0].extend([con_alerta]*len(list(bien_alertados)))
        listado_mal_alertados[0].extend([con_alerta]*len(list(mal_alertados)))

        listado_bien_alertados[1].extend(list(bien_alertados))
        listado_mal_alertados[1].extend(list(mal_alertados))

        struct.append(
            [con_alerta,
             '{} ({})'.format(len(alertados), len(alertados_severos)),
              '{} ({})'.format(len(bien_alertados), len(bien_alertados_severos)),
             ((len(bien_alertados) / len(alertados)) if len(alertados) >  0 else 0)*100, 
             (len(alertados) / len(totales_periodo))*100,
             (len(bien_alertados) / len(malos) if len(malos) > 0 else 0)*100
            ]
        )
    
    df_bien_alertados = pd.DataFrame(zip(*listado_bien_alertados), columns=['nombre_alerta', 'cod_unico'])
    df_bien_alertados = pd.crosstab(df_bien_alertados['cod_unico'], df_bien_alertados['nombre_alerta'])
    df_bien_alertados['nro_reucrrencia'] = df_bien_alertados.sum(axis=1)
    df_bien_alertados['cumple_con_target'] = 1
    #display(df_bien_alertados.head())

    df_mal_alertados = pd.DataFrame(zip(*listado_mal_alertados), columns=['nombre_alerta', 'cod_unico'])
    df_mal_alertados = pd.crosstab(df_mal_alertados['cod_unico'], df_mal_alertados['nombre_alerta'])
    df_mal_alertados['nro_reucrrencia'] = df_mal_alertados.sum(axis=1)
    df_mal_alertados['cumple_con_target'] = 0
    #display(df_mal_alertados.head())
    
    mes = pd.concat(
        [df_bien_alertados, df_mal_alertados], axis=0
    ).reset_index()
    
    mes['PERIODO'] = str(periodos)

    if 'cod_unico' in mes.columns:
        mes['ya_venia_mal'] = mes['cod_unico'].apply(lambda _: _ in ya_vienen_mal).astype(int)
    
    struct = pd.DataFrame(
        struct, columns=['NOMBRE ALERTA', 'ALERTADOS', 'CORRECTOS', 'EFECTIVIDAD', 'CANTIDAD', 'COBERTURA']
    ).sort_values(
        by=['EFECTIVIDAD'], 
        ascending=False
    )
    
    return struct, mes.fillna(0)




def corr_detail(df_corr, min_value=0.75, show_detail=True, col_target='target'):
    
    corr_taret = df_corr[col_target].sort_values(ascending=False).apply(lambda _: abs(_)).sort_values(ascending=False)
    
    from itertools import combinations
    def add_dicc(key, val, num, dicc):
        if key in dicc:
            dicc[key].append((val, num))
        else:
            dicc[key] = [(val, num)]
        
    set_unique, list_detected = set(), []
    dicc_detected = {}
    

    for cols in combinations(list(df_corr.columns), 2):
        corr_columns = np.fabs(df_corr[cols[0]][cols[1]])
        
        if corr_columns >= min_value:
            set_unique.update(cols)
            list_detected.extend(list(cols))
            add_dicc(cols[0], cols[1], corr_columns, dicc_detected)
            add_dicc(cols[1], cols[0], corr_columns, dicc_detected)        
            
    print("ANALISIS CORRELACION ENTRE COLUMNAS :")
    
    for colc, cant in sorted(
        [(col, list_detected.count(col)) for col in set_unique], key=lambda _: _[1], reverse=True):
        print("/"*30)
        print("-> ", colc, ' :::: ',cant, ' ///// ', corr_taret[colc])
        if show_detail:
            for _ in dicc_detected[colc]:
                print(" "*10, *_, '///// ',  corr_taret[_[0]])
    del dicc_detected
    del list_detected
    del set_unique