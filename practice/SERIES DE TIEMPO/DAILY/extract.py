#calculo
import numpy as np
import pandas as pd
from IPython.display import display
np.random.seed(123)

#grafico
import matplotlib.pyplot as plt
import seaborn as sns
sns.set(style="whitegrid")

col_proy = 'Vta. Proy'
col_venta = 'VentaNeta'
col_pauta = 'Pauta'

class Extract:
    def __init__(self, data):
        self.data = data
        
        self.last_date_canilla = data.groupby(
            by=['CodigoSapCanilla']
        )[['Fecha', 'Proy Holt', 'VentaNeta']].max()
        print("Total canillas: ", self.last_date_canilla.shape[0])

        self.last_date = str(data.index[-1]).split(' ')[0]
        print('Ultima fecha detectada: ', self.last_date )
        
        self.unique_canillas = {
            code for code in data['CodigoSapCanilla'].unique() \
            if self.validate_date(code) and self.validate_proy(code)
        }
        print("Canillas con ultimas datos no nulos: ", len(self.unique_canillas))
        
    
    def validate_date(self, code):
        return str(self.last_date_canilla['Fecha'][code]).split(' ')[0] == self.last_date
    
    def validate_proy(self, code):
        return str(self.last_date_canilla['Proy Holt'][code]).lower() != 'nan' and \
            str(self.last_date_canilla['VentaNeta'][code]).lower() != 'nan'
    
    @staticmethod
    def venta_pauta(x, y):
        return np.nan if y <= 0 else x
    
    def get_data_pauta(self, code):
        # Obtenemos las columnas de VEntaNeta y Pauta asociadas al canilla
        datus = self.data[self.data['CodigoSapCanilla'] == code][['VentaNeta', 'Pauta']]
        
        # Agregamos un valor nulo en los dias faltantes
        datus['new'] = datus[['VentaNeta', 'Pauta']].apply(
            lambda _: self.venta_pauta(_['VentaNeta'], _['Pauta']), 
            axis=1
        )
        # Retornamos los valores nulos por ausencia, interpoaldos linealmente
        datus['new'].interpolate(method='time', inplace=True)
        return datus['new']
        
    def get_data(self, code):
        # Devuelvo los datos de venta tal cual
        return self.data[self.data['CodigoSapCanilla'] == code]['VentaNeta']
    
    def populate_data(self, code_agencia):
        lista_canillas = set(
            self.data[self.data['CodigoSapAgencia'] == code_agencia]['CodigoSapCanilla'].unique()
        )
        print('Total canillas en agencia: ', len(lista_canillas))
        
        lista_canillas = lista_canillas.intersection(self.unique_canillas)
        print('Canillas en agencia con ultimos datos no nulos: ', len(lista_canillas))
          
        return {
            canilla: {
                'data': self.get_data_pauta(canilla),
            } for canilla in lista_canillas
        }
    
    @staticmethod
    def valid_null(dicc_data):
        cant_nulos = 0
        
        for k, v in dicc_data.items():
            nulos = v.get('data').isnull().sum()
            if nulos:
                print(k, ' : ', nulos, 'de', v.get('data').shape[0])
                cant_nulos +=1
        
        print('\n {} nulos detectados'.format(cant_nulos))
    
    def inspect_dict(self, dicc_data, n=5, init='2019-01-21'):
        cant = 0
        for k, v in dicc_data.items():
            print('Canilla: ', k)
            display(
                self.data[self.data['CodigoSapCanilla'] == k][
                    ['Pauta', 'VentaNeta', 'Proy Holt']][init:self.last_date]
            )
            cant+= 1
            
            if cant >= n:
                break
    
    def cut_serie(self, dicc_data, since='2019-01-20'):
        for k, v in dicc_data.items():
            v['data'] = v.get('data')[:since]
        return dicc_data
    
    def show_percentile(
        self, dicc, list_percentil=[1, 3, 5, 10, 20, 30, 50, 60, 70, 80, 90, 95, 97, 99]):
        list_data = []
        for k, v in dicc.items():
            list_data.append(
                [round(val, 2) for val in np.nanpercentile(v.get('data'), list_percentil)]
            )
        df_percentil = pd.DataFrame(list_data)
        df_percentil.columns = list_percentil
        display(df_percentil)
        del df_percentil
    
    @staticmethod
    def reemplace_percentile(val, val_smaller, val_bigger):     
        if val < val_smaller:
            return val_smaller
        elif val > val_bigger:
            return val_bigger
        return val
    
    def noise_cut(self, data_cut, quantile_5, quantile_95):
        return data_cut.apply(lambda x: self.reemplace_percentile(x, quantile_5, quantile_95))
    
    def noise_control(self, dicc_data, cut_down, cut_up):
        for k, v in dicc_data.items():
            cut_short = int(v.get('data', []).quantile(cut_down))
            cut_big = int(v.get('data', []).quantile(cut_up))     
            
            v['data_cut'] = self.noise_cut(v.get('data', []), cut_short, cut_big)
        return dicc_data
    
    @staticmethod
    def plot_diff(data, data_cut, name, order, axes):
        plt.hold(True)
        data.plot(ax=axes[order], legend='a')
        data_cut.plot(
            ax=axes[order], 
            title="Reducción de ruido - Ventas Canilla {}".format(name),
            legend='b'
        )
    
    def plot_diff_noise(self, dicc_data, n=5):
        fig, axes = plt.subplots(nrows=n, ncols=1, figsize=(15, n*5))
        order = 0
        for k, v in dicc_data.items():
            self.plot_diff(
                v.get('data'), v.get('data_cut'), k, order, axes
            )
            order += 1
            if n and order >= n:
                break


class MYExtract(Extract):
    
    def __init__(self, data, since='2019-01-21', until='2019-01-27', until_train='2019-01-20'):
        self.since = since
        self.until = until
        self.until_train = until_train
        self.data = data
        
        self.last_date_canilla = self.data[:until].groupby(
            by=['CodigoSapCanilla']
        )[['Fecha', col_proy, col_venta]].max()
        
        print("Detección de valores nulos en pronosticos o ventas netas")
        display(
            self.last_date_canilla[
                (self.last_date_canilla[col_proy].isnull()) | (self.last_date_canilla[col_venta].isnull())
            ]
        )
        print("Total canillas: ", self.last_date_canilla.shape[0])
        
        self.unique_canillas = {
            code for code in data['CodigoSapCanilla'].unique() \
            if self.validate_proy(code)
        }
        print("Canillas a analizar: ", len(self.unique_canillas))
        
        # Creamos una columa que indique el dia de semana  
        self.data['weekday'] = self.data['Fecha'].dt.weekday
        self.list_days = list(data['weekday'].unique())
        print("Columna de dias de semana creada")
    
    def validate_proy(self, code):
        return str(self.last_date_canilla[col_proy][code]).lower() != 'nan' and \
            str(self.last_date_canilla['VentaNeta'][code]).lower() != 'nan'
    
    def procces_day(self, data, num_day):
        df3 = data[data['weekday'] == num_day].copy()
        col, new_col = 'VentaNeta', 'new'
        
        """
        METODO DE AUTOCOMPLETADO 
        """
        if df3[col][-4:].mean() == df3[col][-1] and df3[col][-4:].mean() == df3[col][-2] and df3[col][-4:].mean() < 2:
            print("Se detecto una relacion lineal : ", df3[col][-5:], 'num_day ', num_day)
            return df3[col]
        
        mean = df3[col].median()
        df3[col] = df3[['Pauta', col]].apply(
            lambda _: _[col] if _['Pauta'] > 0 else np.nan, axis=1
        )
        df3[col].fillna(mean, inplace=True)
        return df3[col]
        
    def get_data_pauta_weekday(self, code):
        # Obtenemos las columnas de VEntaNeta y Pauta asociadas
        data_canilla = self.data[
            self.data['CodigoSapCanilla'] == code
        ][['VentaNeta', 'Pauta', 'Fecha', 'weekday']][:self.until_train].copy()
        
        # Deteccion de casos con demasiadas ausencias
        if data_canilla[data_canilla['Pauta'] == 0].shape[0] / data_canilla.shape[0] > 0.5:
            return 'Cantidad de ausencia supera el 50% de casos reportados'
                
        dicc_days = {}
        for num_day in self.list_days:
            dicc_days[num_day] = self.procces_day(data_canilla, num_day)
        
        return dicc_days
    
    def populate_data(self, code_agencia):
        lista_canillas = set(
            self.data[self.data['CodigoSapAgencia'] == code_agencia]['CodigoSapCanilla'].unique()
        )
        print('Total canillas en agencia: ', len(lista_canillas))
        
        lista_canillas = lista_canillas.intersection(self.unique_canillas)
        print('Canillas a trabajar: ', len(lista_canillas))
        
        dicc = {}
        for canilla in lista_canillas:
            response = self.get_data_pauta_weekday(canilla)
            
            if isinstance(response, str):
                print("\n DETECCION DE CASO INVALIDO ", canilla)
                print(response)
                fig, axes = plt.subplots(nrows=1, ncols=1)
                self.data[self.data['CodigoSapCanilla'] == canilla]['VentaNeta'].plot(
                    legend=True, ax=axes, title=canilla)
                print('/'*30)
            else:
                dicc[canilla] = response
        """
        for k, v in dicc.items():
            fig, axes = plt.subplots(nrows=7, ncols=1, figsize=(13,15))
            for num_day, datus in v.items():
                datus.plot(
                    legend=True, ax=axes[num_day], title='{} - {}'.format(k, num_day)
                )
                self.data[
                    (self.data['CodigoSapCanilla'] == k) & (self.data['weekday'] == num_day)
                ]['VentaNeta'].plot(
                    legend=True, ax=axes[num_day]
                )
         """
        return dicc
    
    @staticmethod
    def valid_null(dicc_data):
        cant_nulos = 0
        
        for k, v in dicc_data.items():
            for num_day, datus in v.items():
                nulos = datus.isnull().sum()
                if nulos:
                    print(k, ' __ ', num_day ,' : ', nulos, 'de', v.get('data').shape[0])
                    cant_nulos +=1
        
        print('\n {} nulos detectados'.format(cant_nulos))