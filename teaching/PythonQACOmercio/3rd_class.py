mydict = {
	'damas': ['Naty', 'Raquel'],
	'edad_promedio': 25,
	'subcaja': {
		'class': 2,
		'teacher': 'Victor'
	}
}
print(mydict)

mydict['edad_promedio'] = 26
mydict['edad_minima'] = 21
print(mydict)

print("="*20)
print('hora' in mydict)
print('subcaja' in mydict)
print("="*20)

print(mydict.keys())
print(mydict.values())
print("="*20)

print(mydict['edad_minima'] + 20)
print(mydict['damas'] + [20])

mydict['subcaja']['cualquiera'] = 'cualquiera'
print(mydict)

print(mydict.get('hora', 'sigue nomas'))


#### Colecciones por comprension


#A = {x/x pertence N, talque 2 < x < 10}

# CONDICIONALES:
print('%'*10)
if 'hora' in mydict:
	print('hora es una llave del diccionario')
else:
	print("NO esta")

print('%'*10)
num = 16
if num < 4:
	print('Unos cuantos gatos')
elif num < 8:
	print('Hay un manchita ahi')
elif num <= 10:
	print('Hay un manchita seria')
else:
	print('Son un manchon')

# FOR
print('\n'*3)
lista = ['sueno', 'subcaja', 'damas', 'noche']
new = []

for val in lista:
	if val in mydict:
		new.append(
			mydict.get(val)
		)
	else:
		print('NO esta encuentra {} - {} , {}'.format(val, '&', '/'))

print(new)


#######    DICCIONARIOS COMO CASE

operacion = 'division'
val1 = 2
val2 = 3

print("\n"*2, '='*20)
print("Resultado ",)
if operacion == 'suma':
	print(val1 + val2)
elif operacion == 'resta':
	print(val1 - val2)
elif operacion == 'division':
	print(val1 / val2)
elif operacion == 'multiplicacion':
	print(val1 * val2)
else:
	print('Operador no identificado')

print("   ")




# COMPRENSION
print('\n'*3, '='*20)
otro_new = []
print(lista)
for val in lista:
	if val in mydict:
		otro_new.append(mydict.get(val))

print(otro_new)

# otro_new = [val talque val pertenece lista, si val esta en mydict]

again_new = [mydict.get(val) for val in lista if val in mydict]
print(again_new)



































































 