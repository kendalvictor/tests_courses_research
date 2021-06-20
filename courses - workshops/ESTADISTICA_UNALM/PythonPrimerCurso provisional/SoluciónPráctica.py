##Actividad N°5
import numpy as np
import matplotlib.pyplot as plt
from sklearn.datasets import load_iris
iris = load_iris()
datos = iris.data.T
plt.figure()
plt.subplot(221)
plt.hist(datos[0], bins=10, density=True, alpha=0.5, 
         histtype='stepfilled', color='steelblue',
         edgecolor='none');
plt.subplot(222)
plt.hist(datos[1], bins=10, density=True, alpha=0.5, 
         histtype='stepfilled', color='steelblue',
         edgecolor='none');
plt.subplot(223)
plt.hist(datos[2], bins=10, density=True, alpha=0.5, 
         histtype='stepfilled', color='steelblue',
         edgecolor='none');
plt.subplot(224)
plt.hist(datos[3], bins=10, density=True, alpha=0.5, 
         histtype='stepfilled', color='steelblue',
         edgecolor='none');






