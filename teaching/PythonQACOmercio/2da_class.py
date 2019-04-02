# NUMBER
import math

# SUMA 
print(4 + 5)

# RESTA
print(12 - 3)

#MULTIPLICAION
print( 3 * 3)

# DIVISION
print(81 / 9)

# DIVISION ENTERA
print(81 // 9)

# potencia
print( 3 **2)

# RAIZ
print(math.sqrt(81))

# RESIDUO
print(7 % 2)


# LISTAS, TUPLAS Y CONJUNTS

mylista = [1, 3, 45, 67, 'n', 'vrughugth']
mytupla = (6, 7, 8, 9, 'gtgrtgrt', 'hola')

mylista.append('hola')
print(mylista)


print(mylista[0], mytupla[0], mylista[-1], mytupla[-1])
print(mylista[:600], mylista[2:-1], mytupla[:3], mytupla[-3:])

# COPIAS
print("="*20)
print("="*20)

print(mylista)
copia = mylista[:]
print(copia)

copia.append(9999)
print("-"*10)
print(mylista)
print(copia)


copia_tupla = mytupla[:]
print(copia_tupla)

# CONCATENAR
print('/'*20)
print(mylista + [3,5,87,6666])
print(mytupla + (333, 777))


# CONJUNTOS
print('&'*20)
mylista.extend([1, 3 , 'hola'])
print(mylista)

myset = set(mylista)
print(myset)

sethola = {'hola', 56, 4 ,5, 1}
print(sethola)

print('interseccion')
print(myset.intersection(sethola), myset & sethola)
print('union')
print(myset.union(sethola), myset | sethola )
print('diferencia de un lado')
print(myset.difference(sethola), myset - sethola)
print('diferencia del otro')
print(sethola.difference(myset), sethola - myset)

print("/"*20)
myset.add(2)
myset.update([1,2,67, 'soynuevo'], (1, 3, 9, 4), {67, 9, 1, 'hola'})
listresult = list(myset)
print(listresult)


# DICCIONARIOS
print("()()()"*15)
mydict = {
	'damas': ['Naty', 'Raquel'],
	'edad_promedio': 25,
	'subcaja': {
		'class': 2,
		'teacher': 'Victor'
	}
}

mydict['hora'] = '7pm'
print(mydict)


print('a' in 'abc')
print(1 in mylista)
print('hora' in mydict)


print(mydict['damas'])
print(mydict['damas'][0])
print('Naty' in mydict['damas'])


mydict['subcaja']['cualquiera'] = 'cualquiera'
print(mydict['subcaja'])


print(mydict['feefrefeerr'])

















































