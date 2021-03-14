# Nativos
import hashlib
import glob
import re
import xlrd

# Data
import pandas as pd
from IPython.display import display
from unicodedata import normalize, category


class ParseData:
    def __init__(self, ruta, n_columns=5):
        self.extension = ruta.split('.')[-1]
        self.cols_select = ['dni', 'tipodocumento', 'nombre', 'segmento', 'codclaveciv']
        self.n_columns = n_columns
        self.df = pd.read_excel(ruta, usecols=self.cols_select)

        display(self.df.head())

        self.run_validation()

        self.export_tsv()
        
    
    def run_validation(self):
        self.print_result(
            'No de columnas es igual a {}'.format(self.n_columns),
            self.df.shape[1] == self.n_columns
        )

        # Limpieza de caracteres extraños 
        for col in self.df.columns:
            self.df[col] = self.df[col].astype('str').apply(self.clean_text)

    def export_tsv(self):
        self.df.to_csv(ruta.replace(self.extension, 'tsv'), sep='\t', index=False)

    @staticmethod
    def print_result(mensaje, booleano):
        print(mensaje, "."*15, 'ok' if booleano else 'X')

    @staticmethod
    def fix_print(val, section):
        print("/n /"*45, section)
        print(val)
        print("/"*50)

    @staticmethod
    def clean_text(text_nasty):
        return ''.join(
            (_ for _ in normalize('NFD', text_nasty) if category(_) in ['Ll', 'Lu', 'Zs', 'Nd'])
        ).strip()

print("\n", "/"*5, " VAIDACION DE FORMATO ", "/"*5, "\n")

for ruta in glob.iglob('data/*.xls*', recursive=True):
    print("> ", ruta)
    parser = ParseData(ruta)
    print("\n")



    # print(parser.shape)
    #display(parser.head())

    """
    # Conteto de valores nulos
    print(parser.isnull().isnull())


    # Validacion de numero de columnas
    if parser.columns.shape[0] != 5:
        print("> ", textname, " no posee 5 columnas")

    # Validacion de duplicados
    n_shape = parser.shape[0]
    parser = parser.drop_duplicates()
    new_shape = parser.shape[0]

    if n_shape != new_shape:
        print("Se evidencia las presencia de filas duplicadas")

    
    """

for ruta in glob.iglob('data/*.tsv'):
    print("> ", ruta)
    tsvview = pd.read_csv(ruta, sep='\t')
    display(tsvview.head())
    print("\n")

        

    
    
    


