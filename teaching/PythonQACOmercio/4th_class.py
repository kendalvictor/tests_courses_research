mydict = {
	'damas': ['Naty', 'Raquel', 'Frescia'],
	'edad_promedio': 25,
	'subcaja': {
		'class': 4,
		'teacher': 'Victor'
	}
}

lista = ['sueno', 'subcaja', 'damas', 'noche']

# otro_new = [val talque val pertenece R, si val esta en mydict]

again_new = [mydict.get(val) for val in lista if val in mydict]

tupla_c = (x for x in mydict.get('damas'))

dicc_c = {k:v for k, v in mydict.get('subcaja').items()}

print(again_new)
print(tupla_c)
print(dicc_c)

print("/"*30)
for k, v in dicc_c.items():
	print(k, v)

print("="*30)
for k in dicc_c:
	print(k)


range_example = range(0, 10)
for val in range_example:
	print(val)

for val in range_example:
	print(val)


print('\n'*5)
def procesador(val1, val2):
	print(val1 + val2)

def ventilador(val3, val4, val5):
	return val3 + val4 + val5


print(ventilador(6,7, 9))
print(ventilador('5','4', '11'))

print('\n'*5)
lista_recuerdo = [3,4,5,6]

lista_recuerdo.append(7)
print(lista_recuerdo)

#CALCULARODR FUNCION

def calculadora(*args, **kwargs):
	print(kwargs)
	operacion = kwargs.get('operacion', 'suma')
	if len(args) < 2:
		return 'Debe ingresar dos valores como minimo'

	print(args)
	val1 = args[0]
	val2 = args[1]

	if operacion == 'suma':
		return sum(args)
	elif operacion == 'resta':
		return val1 - val2
	elif operacion == 'division':
		return val1 / val2
	elif operacion == 'multiplicacion':
		return val1 * val2
	else:
		return 'Operador no identificado'

result = calculadora(5, 6, 8, 9, 0 , 5, 7, 8, 9, 0,
					 operacion='division')
print(result)

# DICCIONARIO COMO CONDICIONAL

def suma(x, y):
	return x + y

dicc_calc = {
	'suma': suma,
	'resta': lambda x, y: x -y,
	'division': lambda x, y: x / y,
	'multiplicacion': lambda x, y: x * y
}

print('\n'*5)
def calc(val1, val2, operacion='suma'):
	return dicc_calc.get(operacion)(val1, val2)

result = calc(6, 7)
print(result)






















































