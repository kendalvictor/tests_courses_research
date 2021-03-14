class Carro:
	def __init__(self, gasolina):
		self.gasolina = gasolina
		print("Tenemos ", gasolina, " litros de gasolina")

	def arrancar(self):
		if self.gasolina > 0:
			print(" Arranca")
		else:
			print(" No arranca")

	def conducir(self):
		if self.gasolina > 0:
			self.gasolina -= 1
			print("Quedan ", gasolina, " litros de gasolina")
		else:
			print("No se mueve")

	@classmethod
	def metodo_de_clase(cls):
		print("cls ", cls)

	@staticmethod
	def metodo_estatico():
		print('hola')

class taxi(Carro):
	def arrancar(self):
		super(Taxi, self).

Carro.metodo_estatico()
