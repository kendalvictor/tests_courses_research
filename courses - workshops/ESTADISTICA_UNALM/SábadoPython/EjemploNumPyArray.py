import numpy as np
vector_ceros = np.zeros(5)
matriz_ceros = np.zeros((5,3))

vector_ceros
matriz_ceros

x = np.array([1,2,3])
y = np.array([2,4,6])

A = [[1,3],[5,9]]

B = np.array([[1,3],[5,9]])

B.transpose()

x = np.array([1,2,3])
y = np.array([2,4,6])
X = np.array([[1,2,3],[4,5,6]])
Y = np.array([[2,4,6],[8,10,12]])

x[2]

x[0:2]

z = x + y

Y[:,1]

X[:,1] + Y[:,1]

X[1,:]

X[1,:] + Y[1,:]

X[1]

## Recordemos que:
[1,2,3] + [2,4,6]

np.array([1,2,3]) + np.array([2,4,6])

z1 = np.array([1,3,5,7,9])

z2 = z1 + 1

ind = [0,2,3] # índices como una lista

z1[ind]

ind = np.array([0,2,3]) # índices como un np.array

z1 > 6

z1[z1>6]

z2[z1>6]

ind = z1 > 6

z1[ind]

z2[ind]

z1 = np.array([1,3,5,7,9])

w = z1[0:3]

w[0] = 3

z1 = np.array([1,3,5,7,9])

ind = np.array([0,1,2])

w = z1[ind]

w[0] = 3

##Construyendo secuencias:

np.linspace(0,100,10) ##espaciado lineal desde 0 a 100 con 10 elementos

np.logspace(1,2,10) ##espaciado logarítmico desde el log(10)= 1 y log(100)=2 con 10 elementos

np.logspace(np.log10(250),np.log10(500),10)


X = np.array([[1,2,3],[4,5,6]])
X.shape ## Determina el tamaño de las dimensiones
X.size ## Determina el número de elementos del arreglo


x = np.random.random(10) ## genera 10 números aleatorios de una distribución uniforme de 0 a 10
np.any(x > 0.9)
np.any(x >= 0.1)

