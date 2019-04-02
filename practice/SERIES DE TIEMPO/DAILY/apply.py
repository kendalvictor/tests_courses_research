import numpy as np
import pandas as pd
from timelines_utils import *
from scipy.optimize import minimize

def apply_holt_winters(data, range_fold=range(6, 13, 2), range_slen=range(7, 8, 1),
                      n_preds=7, first=True, extra_fold=range(3, 4 ,1),
                       extra_slen=range(3,7,1)):
    list_result = []
    if first:
        print("""
            Se procederá a una estimacion del error subdividiendo los folds usados
            en nuestra validación cruzada y las estacionales relativamente posibles
            en un contexto de no tenerlas bien marcas \n
        """)
    
    for fold in range_fold:
        print("Folds: ", fold)
        for slen in range_slen:
            print(" "*6, "Slen: ", slen, end=', ')
            # Se inicializan los parámetros del modelo:  alfa, beta y gamma.
            val_initials = [0, 0, 0.1, slen]
            
            try:
                # Se procede a minimizar el error 
                opt = minimize(
                    timeseriesCVscore, 
                    x0=val_initials,
                    args=(data, mean_squared_error, fold, np.mean),
                    method="TNC", 
                    bounds=((0, 1), (0, 1), (0, 1), (range_slen.start, range_slen.stop +1)),
                    options={'maxiter': 100, 'disp': True}
                )
                result = (opt.fun, opt.x)
                # Se agrega visualizacion del error y parametros
                print("Error promedio: ", result[0])

                list_result.append(result)
            except Exception as e:
                print("Fallo (dimensiones): ", str(e))
        print("="*30)
 
    
    # Se ordenan los valores acorde al error para hallar el mìnimo a nivel de fold
    list_result_select = sorted(
        list_result,
        key=lambda _: _[0]
    )
    
    print('\n')
    for rr in list_result:
        print(rr)
    
    # Se procede a tomar los valores óptimos.
    alpha_final, beta_final, gamma_final, slen = list_result_select[0][1]
    print('\n'*2, "="*20, ' valores finales: ')
    print(alpha_final, beta_final, gamma_final, slen)
    
    # Se entrena un modelo con los valores optimos y se retorna
    model = HoltWinters(
        data, slen=slen, 
        alpha=alpha_final, 
        beta=beta_final, 
        gamma=gamma_final, 
        n_preds=7
    )
    model.triple_exponential_smoothing()
    return model