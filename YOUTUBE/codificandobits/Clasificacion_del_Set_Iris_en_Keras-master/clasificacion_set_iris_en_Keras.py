# Set de datos: Iris dataset. 
#
# En total son 150 datos, y cada uno está representado con 4 características:
# 'SepalLengthCm', 'SepalWidthCm', 'PetalLengthCm' y 'PetalWidthCm'.
#
# Para la clasificación se tienen tres categorías de flores: 'Iris-setosa',
# 'Iris-versicolor' y 'Iris-virginica'
#
# En este ejemplo de clasificación se usarán únicamente dos características
# durante el entrenamiento del modelo: 'SepalLengthCm' y 'SepalWidthCm'
# 
# codificandobits.com - 2018

import pandas as pd
from sklearn.preprocessing import LabelEncoder
import numpy as np
import matplotlib.pyplot as plt

from keras.models import Sequential
from keras.layers import Dense
from keras.optimizers import SGD
from keras.utils import np_utils

#
# Funciones auxiliares: dibujar frontera de decisión
#
def dibujar_frontera(X,Y,modelo,titulo):
    # Valor mínimo y máximo y rellenado con ceros
    x_min, x_max = X[:, 0].min() - .5, X[:, 0].max() + .5
    y_min, y_max = X[:, 1].min() - .5, X[:, 1].max() + .5
    h = 0.01

    # Grilla de puntos
    xx, yy = np.meshgrid(np.arange(x_min, x_max, h), np.arange(y_min, y_max, h))

    # Predecir categorías para cada punto en la gruilla
    Z = modelo.predict_classes(np.c_[xx.ravel(), yy.ravel()])
    Z = Z.reshape(xx.shape)

    fig = plt.figure()
    plt.contourf(xx, yy, Z, cmap=plt.cm.Set1, alpha=0.8)

    Y = np.argmax(Y,axis=1)
    idx0 = np.where(Y==0)
    idx1 = np.where(Y==1)
    idx2 = np.where(Y==2)
    plt.scatter(X[idx0,0],X[idx0,1],c=(1,0,0), edgecolor='k', label='Iris setosa')
    plt.scatter(X[idx1,0],X[idx1,1],c=(124./255.,44./255.,169./255.),edgecolor='k', label='Iris-versicolor')
    plt.scatter(X[idx2,0],X[idx2,1],c=(128./255.,128./255.,128./255.),edgecolor='k', label='Iris-virginica')
    plt.legend(fontsize=8,loc='upper right')
    plt.xlim(xx.min(), xx.max())
    plt.ylim(yy.min(), yy.max())
    plt.title(titulo)

    plt.xlabel('SepalLengthCm')
    plt.ylabel('SepalWidthCm')
    plt.show()

#
# Lectura de los datos y visualización. Se usarán únicamente "SepalLengthCm"
# y "SepalWidthCm" para la clasificación.
#

datos = pd.read_csv('Iris.csv',usecols=[1,2,5])


# Crear datos de entrada (X) y de salida (Y)
X = datos.iloc[:,0:2].values
Y_str = datos.iloc[:,2].values

# Convertir "labels" de caracteres a números
encoder = LabelEncoder()
encoder.fit(Y_str)
Y_num = encoder.transform(Y_str)

# Convertir "Y_num" a representación "one-hot", requerida por Keras durante
# el entrenamiento
n_clases = 3
Y = np_utils.to_categorical(Y_num,n_clases)

# Graficar los datos
idx0 = np.where(Y_num==0)
idx1 = np.where(Y_num==1)
idx2 = np.where(Y_num==2)
plt.scatter(X[idx0,0],X[idx0,1],c=(1,0,0), edgecolor='k', label='Iris setosa')
plt.scatter(X[idx1,0],X[idx1,1],c=(124./255.,44./255.,169./255.),edgecolor='k', label='Iris-versicolor')
plt.scatter(X[idx2,0],X[idx2,1],c=(128./255.,128./255.,128./255.),edgecolor='k', label='Iris-virginica')
plt.legend(fontsize=8,loc='upper right')
plt.xlabel('SepalLengthCm')
plt.ylabel('SepalWidthCm')
plt.show()

#
# Crear el modelo:
# - Entrada: 2 dimensiones (SepalLengthCm y SepalWidthCm)
# - Salida: 3 dimensiones (3 clases)
# - Activación: softmax
#

np.random.seed(1)           # Para reproducibilidad del entrenamiento
input_dim = X.shape[1]
output_dim = Y.shape[1]

modelo = Sequential()
modelo.add(Dense(output_dim, input_dim=input_dim, activation='softmax'))

# Optimizador, tasa de aprendizaje, función de pérdida y métrica de desempeño
sgd = SGD(lr=0.1)
modelo.compile(loss='categorical_crossentropy', optimizer=sgd, metrics=['accuracy'])

#
# Entrenamiento. Se usarán 2000 iteraciones y un batch_size igual al número total de datos
#

n_its = 2000
batch_size = X.shape[0]
historia = modelo.fit(X,Y,epochs=n_its,batch_size=batch_size,verbose=2)

#
# Resultados
#

# Graficar comportamiento de la pérdida y de la precisión
plt.subplot(1,2,1)
plt.plot(historia.history['loss'])
plt.ylabel('Pérdida')
plt.xlabel('Epoch')
plt.title('Comportamiento de la pérdida')

plt.subplot(1,2,2)
plt.plot(historia.history['acc'])
plt.ylabel('Precisión')
plt.xlabel('Epoch')
plt.title('Comportamiento de la precisión')

ax = plt.gca()
ax.yaxis.set_label_position("right")
ax.yaxis.tick_right()

plt.show()

# Dibujar frontera de decisión
dibujar_frontera(X,Y,modelo,'Fronteras de decisión después del entrenamiento')
