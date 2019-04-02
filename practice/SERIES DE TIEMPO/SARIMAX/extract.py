#calculo
import numpy as np
import pandas as pd
from IPython.display import display

#grafico
import matplotlib.pyplot as plt
import seaborn as sns
sns.set(style="whitegrid")

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
    
    def get_data_del_not_pauta(self, code):
        # Obtenemos las columnas de VEntaNeta asociada al canilla
        return self.data[
            (self.data['CodigoSapCanilla'] == code) & (self.data['Pauta'] > 0)
        ]['VentaNeta']
        
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
                'data': self.get_data(canilla),
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




    