#calculo
import numpy as np
import pandas as pd
from IPython.display import display
np.random.seed(123)

col_proy = 'Vta. Proy'
col_venta = 'VentaNeta'
col_pauta = 'Pauta'

def compare_result(data, codigo_canilla, dicc_predict, order, since_date_1, until_date_1):
    result = sorted(dicc_predict.items(), key=lambda _: _[0])
    
    result = pd.DataFrame(
        data=[_[1].values[0] if isinstance(_[1], pd.Series) else _[1] for _ in result],
        index=[_[0] for _ in result] 
    )
    result.columns = ['New_Prediction']
    result['weekday'] = result.index
    
    old_result = pd.DataFrame(
        data[data['CodigoSapCanilla'] == codigo_canilla
            ][['VentaNeta', col_proy, 'weekday', 'Fecha', 'Pauta']][since_date_1:until_date_1]
    )
    result = pd.merge(result, old_result, on='weekday', how='inner')
    del old_result
    
    result['diff_venta_holt'] = np.abs(result['VentaNeta'] - result[col_proy])
    result['diff_venta_holtwinters'] = np.abs(result['VentaNeta'] - result['New_Prediction'])
    result.index = result.Fecha
    del result['Fecha']
    del result.index.name
    
    result['round_ProyHolt'] = result[col_proy].apply(lambda _: round(_) if _ > 0 else 0)
    result['round_HoltWinters'] = result['New_Prediction'].apply(lambda _: round(_) if _ > 0 else 0)
    
    # Pauta Proyectada
    def get_constante_venta(weekday):
        _last = pd.DataFrame(
            data[
                (data['CodigoSapCanilla'] == codigo_canilla) & (data['weekday'] == weekday)
            ]['VentaNeta'][:since_date_1][-6:-1]
        )
 
        mean_last = _last.values.mean()
        if mean_last <= 2:
            return 0
        elif mean_last <= 16:
            return 1
        else:
            return 2
    
    result['cte_dev'] = result['weekday'].apply(lambda _: get_constante_venta(_))
    
    constante_devolucion = 0
    constante_venta = 0
    
    result['round_ProyHolt'] = result[['round_ProyHolt', 'cte_dev']].apply(
        lambda _: _['round_ProyHolt'] + _['cte_dev']  + constante_venta, axis=1
    )
    result['round_HoltWinters'] = result[['round_HoltWinters', 'cte_dev']].apply(
        lambda _: _['round_HoltWinters'] + _['cte_dev']  + constante_venta, axis=1
    )
    
    result['diff_int_ventaholt'] = result['VentaNeta'] - result['round_ProyHolt']
    result['diff_int_ventawinters'] = result['VentaNeta'] - result['round_HoltWinters']
    
    # Se considera perdida los casos donde el modelo pronostique por debajo de la venta real
    result['perdida_holt'] = result['diff_int_ventaholt'].apply(lambda _: _ if _ > 0 else 0)
    result['perdida_winters'] = result['diff_int_ventawinters'].apply(lambda _: _ if _ > 0 else 0)
    
    # Deteccion de canillas que incurren en perdida
    result['cant_perdida_holt'] = result['diff_int_ventaholt'].apply(lambda _: 1 if _ > 0 else 0)
    result['cant_perdida_winters'] = result['diff_int_ventawinters'].apply(lambda _: 1 if _ > 0 else 0)
    
    # Se cuentan los casos donde el pronostico atinó a la venta
    result['idem_holt'] = result['diff_int_ventaholt'].apply(lambda _: 1 if _ == 0 else 0)
    result['idem_winters'] = result['diff_int_ventawinters'].apply(lambda _: 1 if _ == 0 else 0)
    
    # Se considera a una prediccion idonea cuando el pronostico supera a la venta en uno
    result['ok_holt'] = result['diff_int_ventaholt'].apply(lambda _: 1 if _ == -1 else 0)
    result['ok_winters'] = result['diff_int_ventawinters'].apply(lambda _: 1 if _ == -1 else 0)
    
    # Sumatoria de los valores de proyeccciones que superan en mas de 1 a la ventaneta
    result['sobre_holt'] = result['diff_int_ventaholt'].apply(lambda _: np.abs(_) if _ < -1 else 0)
    result['sobre_winters'] = result['diff_int_ventawinters'].apply(lambda _: np.abs(_) if _ < -1 else 0)
    
    # Cant de canillas de los que incurren a superar en mas de uno
    result['cant_sobre_holt'] = result['diff_int_ventaholt'].apply(lambda _: 1 if _ < -1 else 0)
    result['cant_sobre_winters'] = result['diff_int_ventawinters'].apply(lambda _: 1 if _ < -1 else 0)
    
    print('/'*10, "SUMA DE ERRORES", '/'*10, 
          data[data['CodigoSapCanilla'] == codigo_canilla]['NombreAgencia'].unique(),
          codigo_canilla)
    print("PROY HOLT___ decimal: {}  , entera: {}".format(
        sum(np.abs(result['diff_venta_holt'])), sum(np.abs(result['diff_int_ventaholt']))
    ))
    print("HOLT WINTERS___ decimal: {}  , entera: {}".format(
        sum(np.abs(result['diff_venta_holtwinters'])), sum(np.abs(result['diff_int_ventawinters']))
    ))
    
    result['devolucion_real'] = result['Pauta'] - result['VentaNeta']
    
    #LOGICA DE INDICE DE AHORRO
    def calc_indice_ahorro(diff_vta_proy, dev_real, constante_devolucion):
        proy_vta = -1*diff_vta_proy
        
        if proy_vta > 0:
            return proy_vta
        
        elif proy_vta == 0:
            return constante_devolucion
        
        else:
            add = 0 if dev_real > 0 else constante_devolucion
            return np.abs(proy_vta) + add
    
    result['dev_proy_holt'] = result['ok_holt'] + result['sobre_holt']
    result['dev_proy_new'] = result['ok_winters'] + result['sobre_winters']
    
    result['ahorro_holt'] = result[['diff_int_ventaholt', 'devolucion_real', 'cte_dev']].apply(
        lambda _: _['devolucion_real'] - calc_indice_ahorro(_['diff_int_ventaholt'], _['devolucion_real'], _['cte_dev']), axis=1
    )
    result['ahorro_new'] = result[['diff_int_ventawinters', 'devolucion_real', 'cte_dev']].apply(
        lambda _:  _['devolucion_real'] - calc_indice_ahorro(_['diff_int_ventawinters'], _['devolucion_real'], _['cte_dev']), axis=1
    )
    
    # MEDIDA DE REFERENCIA -- ERROR ABSOLUTO
    result['error_abs_holt'] = np.abs(result['diff_int_ventaholt'])
    result['error_abs_new'] = np.abs(result['diff_int_ventawinters'])
    
    # result[col_proy].plot(legend=True, ax=axes[order], title=str(codigo_canilla))
    # result['New_Prediction'].plot(legend=True, ax=axes[order])
    # result['VentaNeta'].plot(legend=True, ax=axes[order])
    display(result)
    return result

def reemplace_percentile(val, val_smaller, val_bigger):     
    if val < val_smaller:
        return val_smaller
    elif val > val_bigger:
        return val_bigger
    return val

def get_type(dicc_data):
    

def noise_control(dicc_data):
    for k, v in dicc_data.items():
        for num_day, datus in v.items():
            #fig, axes = plt.subplots(nrows=1, ncols=1)
            #datus.plot(legend=True, ax=axes, title='{} - {}'.format(k, num_day))
            
            q75, q25 = np.percentile(datus, [75 ,25])
            iqr = q75 - q25
            size_outlier = (datus.max() - datus.min()) - iqr
            
            if size_outlier < 5:
                cut_up = 97 / 100
                cut_down = 3 / 100
            elif size_outlier < 10:
                cut_up = 95 / 100
                cut_down = 5 / 100
            else:
                cut_up = 90 / 100
                cut_down = 10 / 100

            quantile_max = int(datus.quantile(cut_up))
            quantile_min = int(datus.quantile(cut_down))
            
            if datus[-4:].mean() == datus[-1] and datus[-4:].mean() == datus[-2] and datus[-4:].mean() < 2:
                print("Relacion Lineal : ", k, num_day, datus[-5:].values, datus[-1])
            else:
                print("()() ", k , cut_up, '=', quantile_max, '/// ', cut_down, '=', quantile_min)
                v[num_day] = datus.apply(lambda x: reemplace_percentile(x, quantile_min, quantile_max))
            # v[num_day].plot(legend=True, ax=axes)
            
    return dicc_data

def calc_result(data, dicc_data, dicc_data_result, since_date_1, until_date_1, export_name='result'):
    order = 0
    df_result = None
    
    for k, v in dicc_data.items():
        
        # Se obtiene el dataframe con los resultados semananales por canilla
        response = compare_result(
            data,                      # data total
            k,                         # codigo canilla
            dicc_data_result[k],       # diccionario de resultados 
            order,
            since_date_1, until_date_1
        )
        
        if df_result is None:
            df_result = response
        else:
            df_result = pd.concat([df_result, response], ignore_index=True)
        
        order += 1
        
    del dicc_data
    del dicc_data_result
    
    list_head = ['Pauta', 'VentaNeta', 
                 'devolucion_real', 'round_ProyHolt',  'error_abs_holt',  'cant_perdida_holt', 'perdida_holt', 'idem_holt',
                 'ok_holt', 'sobre_holt', 'dev_proy_holt', 'ahorro_holt', 'round_HoltWinters', 'error_abs_new', 
                 'cant_perdida_winters', 'perdida_winters', 'idem_winters', 'ok_winters', 'sobre_winters', 'dev_proy_new',
                 'ahorro_new'
                ]
    
    dicc_show = {head: np.sum for head in list_head[2:]}
    
    df_result[['weekday'] + list_head].to_csv('{}.csv'.format(export_name), index=False)
    
    display(df_result.groupby(by=['weekday']).agg({
        'Pauta': np.sum,
        'VentaNeta': np.sum
    }))
    
    return df_result.groupby(by=['weekday']).agg(dicc_show)
    