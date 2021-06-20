##Secuencias
###En Python existen tres tipos de secuencias: list, tuple y range object
A=[3,1,0,8,9]
print(A[0])
print(A[-0])
print(A[-4])
# operador "slicing"
print(A)
print(A[0:2])
B=(1,2,3)
print(B)
print(B[0])
print(B[-0:0])
print(A[-0:0])
print(A[0:-0])
print((1,2,3)[-0:0])
print(B[-2:0])
print(B[0:2])
print(B[0:-2])

##Listas
## Los list son mutables, strings son list inmutables de caracteres individuales
numeros=[2,4,6,8]
numeros.append(10)
print(numeros)
x=[12,14,16]
numeros + x ##concatena dos listas
numeros.reverse()
print(numeros)
numeros.sort()
print(numeros)

nombres=["Juan", "Ana", "Pedro", "Jorge"]
nombres.sort()
print(nombres)
nombres.reverse()
print(nombres)
ordenados_nombres=sorted(nombres)
print(nombres)
print(ordenados_nombres)
print(len(nombres))

##Tuples
##Son secuencias inmutables usados para almacenar datos heterogénas
T=(1,3,5,7)
len(T)
T + (9,11) ##concatena dos objetos tuples
print(T[2])
x=12.23
y=23.34
paquete =(x,y) #empaquetar en un tuple los objetos x e y
print(paquete)
print(type(paquete))
(p1,p2)= paquete #desempaqueta un tuple con dos elementos
print(p1)
print(p2)

coordenadas=[(0,0),(1,1),(2,4),(3,9),(4,16),(5,25),(6,36),(7,49),(8,64),(9,81)]

for(x,y) in coordenadas:
    print(x,y)
    
for x,y in coordenadas:
    print (x,y)
c = (2,3)
type(c)
c = (2)
type(c)
c =(2,)
type(c)
c = 2,
type(c)
x = (1,2,3)
x.count(2)

##Ranges
##Son secuencias inmutables de enteros, comunmente usados para loops
list(range(0,5))
list(range(1,6))
list(range(1,13,2))

##Strings
##Son secuencias inmutables de caractares
S="Python"
len(S)
S[0]
S[-1]
S[0:3]
S[-3:]
"y" in S
"Y" in S
"hola" + "mundo"
3*S
"ocho es igual a "+str(8)
dir(str) #lista todos los atributos que son disponibles para strings
help(str.replace)
nombre = "Alicia Sofia"
len(nombre)
nombre.replace("A","a")
nuevo_nombre = nombre.replace("A","a")
type(nuevo_nombre)
nombre = nombre.split(" ")
len(nombre)
type(nombre[1])
nombre[0].upper()
nombre[1].upper()

##Sets
##Los sets de Python son útiles para mantener distintos objetos y se puede realizar operaciones de conjuntos 
##como unión, intersección y diferencias
ids = set() ##crea un set vacío
ids = set ([1,2,4,6,7,8,9])
len(ids)
ids.add(10)
ids.add(2)
ids.pop()
ids.pop()
len(ids)
ids = set(range(10))
hombres = set([1,3,5,6,7])
mujeres = ids - hombres
type(mujeres)
##Operación de conjuntos: unión
todos= hombres | mujeres
##Operación de conjuntos: intersección
todos & set([1,2,3])

palabra = "antidemocracia"
len(palabra)

palabra_set = set(palabra)
len(palabra_set)

##1.2.7: Diccionarios
edad = {}
edad = dict()
edad = {"Pedro":29,"Julia":28,"Maria":30,"Juan":35}
edad["Julia"]
edad["Maria"] = edad["Maria"] + 1
edad["Juan"] += 1
edad["Juan"]
edad.keys()
nombres = edad.keys()
type(nombres)
edad["Pedro"] = 50
edad.values()
edades = edad.values()
edad["Jose"] = 31
"Pedro" in edad
"Carla" in edad
