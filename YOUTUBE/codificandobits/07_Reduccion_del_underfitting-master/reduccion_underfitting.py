import numpy as np
np.random.seed(1)		# Para la reproducibilidad del entrenamiento

from keras.datasets import cifar10
from keras.utils import to_categorical
from keras.models import Sequential
from keras.layers import Dense
from keras.optimizers import SGD

from keras.layers import Conv2D
from keras.layers import MaxPooling2D
from keras.layers import Flatten
from keras.layers import Dropout

import matplotlib.pyplot as plt

#
# 0. Función auxiliar: graficar error y precisión en los sets de entrenamiento y validación
#
def graficar_resultados(historia):
	plt.subplot(1,2,1)
	plt.plot(historia.history['loss'])
	plt.plot(historia.history['val_loss'])
	plt.ylabel('Pérdida')
	plt.xlabel('Iteración')
	plt.legend(['Entrenamiento','Validación'])

	plt.subplot(1,2,2)
	plt.plot(historia.history['acc'])
	plt.plot(historia.history['val_acc'])
	plt.ylabel('Precisión')
	plt.xlabel('Iteración')
	plt.legend(['Entrenamiento','Validación'])

	ax = plt.gca()
	ax.yaxis.set_label_position("right")
	ax.yaxis.tick_right()

	plt.show()


#
# 1. Lectura y pre-procesamiento del dataset
# 

(X_train, y_train), (X_test, y_test)= cifar10.load_data()

# Seleccionar 9 imágenes aleatorias y graficarlas:
for i in range(9):
	ind_img = np.random.randint(low=0,high=X_train.shape[0])
	plt.subplot(3,3,i+1)
	plt.imshow(X_train[ind_img])
	plt.axis('off')
plt.show()

# Codificación one-hot para las categorías
Y_train = to_categorical(y_train)
Y_test = to_categorical(y_test)

# Normalizar pixeles al rango 0-1 (originalmente de 0-255)
X_train = X_train.astype('float32')
X_test = X_test.astype('float32')
X_train = X_train / 255.0
X_test = X_test / 255.0

# "Aplanar" cada imagen, pasando de matrices de 32x32x3 a 3072 (requerido por la red neuronal)
m = X_train.shape[0]			# Número de datos de entrenamiento
n = X_test.shape[0]				# Número de datos de validación
nrows, ncols, nplanos = X_train.shape[1], X_train.shape[2], X_train.shape[3]

X_train = np.reshape(X_train, (m, nrows*ncols*nplanos))
X_test = np.reshape(X_test, (n, nrows*ncols*nplanos))

#
# 2. Creación primera red neuronal:
# - Capa de entrada: su dimensión será 3072 (el tamaño de cada imagen aplanada)
# - Capa oculta: 15 neuronas con activación ReLU
# - Capa de salida: función de activación 'softmax' (clasificación multiclase) y un
#     total de 10 categorías
#

input_dim = X_train.shape[1]
output_dim = Y_train.shape[1]

modelo = Sequential()
modelo.add( Dense(15, input_dim=input_dim, activation='relu'))
modelo.add( Dense(output_dim, activation='softmax'))

# Compilación y entrenamiento: gradiente descendente, learning rate = 0.05, función
# de error: entropía cruzada, métrica de desempeño: precisión

sgd = SGD(lr=0.05)
modelo.compile(loss='categorical_crossentropy', optimizer=sgd, metrics=['accuracy'])

# Para el entrenamiento se usarán 2000 iteraciones y un batch_size de 1024
num_epochs = 2000
batch_size = 1024
historia = modelo.fit(X_train, Y_train, validation_data = (X_test,Y_test),epochs=num_epochs, batch_size=batch_size, verbose=2)
graficar_resultados(historia)

#
# 3. Creación segunda red neuronal:
# - Capa de entrada: su dimensión será 3072 (el tamaño de cada imagen aplanada)
# - Capas ocultas: 30 y 15 neuronas con activación ReLU
# - Capa de salida: función de activación 'softmax' (clasificación multiclase) y un
#     total de 10 categorías
#

input_dim = X_train.shape[1]
output_dim = Y_train.shape[1]

modelo = Sequential()
modelo.add( Dense(30, input_dim=input_dim, activation='relu'))
modelo.add( Dense(15, activation='relu'))
modelo.add( Dense(output_dim, activation='softmax'))

# Compilación y entrenamiento: gradiente descendente, learning rate = 0.05, función
# de error: entropía cruzada, métrica de desempeño: precisión

sgd = SGD(lr=0.05)
modelo.compile(loss='categorical_crossentropy', optimizer=sgd, metrics=['accuracy'])

# Para el entrenamiento se usarán 2000 iteraciones y un batch_size de 1024
num_epochs = 2000
batch_size = 1024
historia = modelo.fit(X_train, Y_train, validation_data = (X_test,Y_test),epochs=num_epochs, batch_size=batch_size, verbose=2)
graficar_resultados(historia)

#
# 4. Creación red convolucional:
# - Conv2D (32 filtros, 3x3) - Conv2D (32 filtros, 3x3) - MaxPooling2D - Dropout
# - Conv2D (64 filtros, 3x3) - Conv2D (64 filtros, 3x3) - MaxPooling2D - Dropout
# - Conv2D (128 filtros, 3x3) - Conv2D (128 filtros, 3x3) - MaxPooling2D - Dropout
# - Flatten - Dense (128) - Dropout - Salida (Dense, 10 neuronas)
#

# Reajustar el tamaño de los datos de entrenamiento y validación (aplanados anteriormente para su uso en redes neuronales)
X_train = np.reshape(X_train,(m,nrows,ncols,nplanos))
X_test = np.reshape(X_test,(n,nrows,ncols,nplanos))

# Creacion de la red convolucional

modelo = Sequential()
modelo.add(Conv2D(32, (3, 3), activation='relu', kernel_initializer='he_uniform', padding='same', input_shape=(32, 32, 3)))
modelo.add(Conv2D(32, (3, 3), activation='relu', kernel_initializer='he_uniform', padding='same'))
modelo.add(MaxPooling2D((2, 2)))
modelo.add(Dropout(0.2))
modelo.add(Conv2D(64, (3, 3), activation='relu', kernel_initializer='he_uniform', padding='same'))
modelo.add(Conv2D(64, (3, 3), activation='relu', kernel_initializer='he_uniform', padding='same'))
modelo.add(MaxPooling2D((2, 2)))
modelo.add(Dropout(0.2))
modelo.add(Conv2D(128, (3, 3), activation='relu', kernel_initializer='he_uniform', padding='same'))
modelo.add(Conv2D(128, (3, 3), activation='relu', kernel_initializer='he_uniform', padding='same'))
modelo.add(MaxPooling2D((2, 2)))
modelo.add(Dropout(0.2))
modelo.add(Flatten())
modelo.add(Dense(128, activation='relu', kernel_initializer='he_uniform'))
modelo.add(Dropout(0.2))
modelo.add(Dense(10, activation='softmax'))

opt = SGD(lr=0.001, momentum=0.9)
modelo.compile(optimizer=opt, loss='categorical_crossentropy', metrics=['accuracy'])

historia = modelo.fit(X_train, Y_train, epochs=100, batch_size=64, validation_data=(X_test, Y_test), verbose=2)
graficar_resultados(historia)
