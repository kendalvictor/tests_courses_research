dicc_clima = {
	'verano': 1,
	'invierno': 0.7,
	'otono': 0.8,
	'primavera': 1.2
}

dicc_zona = {
	'lima': 1.1,
	'lurin': 0.9
}


class EC():
	antiguedad = 180
	nombre_oficlal = 'GRUPO EL COMERCIO'

	def __init__(self):
		pass

	def ventas_diarias(self, clima, zona, venta_dia_semana_anteriro=10):

		return venta_dia_semana_anteriro + 0.7*clima + 0.9*zona + self.antiguedad / 100


e = EC()
print(e.antiguedad)
print(e.nombre_oficlal)

print(e.ventas_diarias(
	dicc_clima.get('verano'),
	dicc_zona.get('lima'),
	10)
)

print('\n'*5)

class Persona():
	edad = 20
	nombre = 'Isaias'

	def __init__(self, edad, nombre):
		self.edad = edad
		self.nombre = nombre
	
	def indice_rendimiento(self, cant_comida, puntaje_meta):
		return self.edad + 0.6*cant_comida + 0.4*puntaje_meta


pp = Persona(27, 'Miriam')
print(pp.edad)
print(pp.nombre)
print(pp.indice_rendimiento(1.3, 5))