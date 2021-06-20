##Dynamic Typing
##Cada objeto en Python tiene valor, tipo e identidad
##Aquí se tiene dos nombres para la misma referencia del objeto
L1=[1,2,3] ##L1 es la referencia al objeto 
L2=L1
L1[0]=11
L1
L2
L1 is L2
L1 == L2
id(L1)
id(L2)
id(L1) == id(L2)
##Un objeto mutable en Python puede tener idéntico contenido, pero ser realmente
##diferentes objetos
L = [1,2,3]
M = [1,2,3]
L == M ##compara elemento por elemento
L is M ## compara si es el mismo objeto
id(L)
id(M)
id(L) == id(M)

L =[1,2,3]
M = L #aquí M es otro nombre para la misma lista
M = list(L) #aquí crea una nueva lista y luega asigna a la lista un nuevo objeto
##crea un nuevo objeto con idéntico contenido a L
M is L
M == L
M = L[:] ##otra forma de crear una copia de una lista usando la sintaxis

##Copies
import copy 
x = [1,[2]] 
y = copy.copy(x) 
z = copy.deepcopy(x) 
y is z

##Statements (expresiones)
##_____________________________
if False: 
    print("False!") 
elif True: 
    print("Now True!") 
else: 
    print("Finally True!")
##_______________________________

##Bucles: For and while
for x in range(10):
    print (x)

nombres = ['Juan','Maria','Carlos']
for nombre in nombres:
    print (nombre)

for i in range(len(nombres)):
    print (i)
    print(nombres[i])

edades = {'Juan':30,'Maria':31,'Carlos':27}
edades.keys()
for nombre in edades.keys():
    print (nombre, edades[nombre])

for nombre in edades:
    print (nombre, edades[nombre])

for nombre in sorted(edades.keys()):
    print (nombre, edades[nombre])

for nombre in sorted(edades.keys(), reverse=True):
    print (nombre, edades[nombre])

x = 1
while x < 8:
    print (x)
    x += 1

##___________________________________

x = list(range(0,10))
x2 = []
for elemento in x:    
    x2.append(elemento**2)
     
cuadrados = [elemento**2 for elemento in x]

##Lectura y escritura de archivos:
for linea in open("archivo1.txt"):
    print(linea)

for linea in open("archivo1.txt"):
    linea = linea.rstrip()
    print(linea)

for linea in open("archivo1.txt"):
    linea = linea.rstrip().split(" ")
    print(linea)

File = open("archivo2.txt","w")
File.write("Bienvenidos \n al curso de Python")
File.close()

##_____________________
##Funciones
def sumaYresta(a,b):
    misuma = a+ b
    miresta = a-b
    return (misuma, miresta)

sumaYdiferencia = sumaYresta ##asigna otro nombre a la función

def modificar(milista):
    milista[0] = milista[0]*20

L=[2,3,4,5,6,8]
modificar(L)

def interseccion(A,B):
    intersec = []
    for elemento in A:
        if elemento in B:
            intersec.append(elemento)
    return intersec


import random
def password(longitud):
    password = ""
    caracteres = "ABCDEFGH"
    for i in range(longitud):
        password = password + random.choice(caracteres)
    return password

##Errores comunes:
L=[2,3,4,5,6]
L[5]
L.add(8)
D = {"1":"hola","2":"saludos","3":"hasta luego"}
D.keys()
D.values()
D[2]
aaa="hola"
aaa[0]="H"
"saludos" + Ana

def suma(n):
    resul = 0
    for i in range(n):
        resul = resul + i
        return resul
