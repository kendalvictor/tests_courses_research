class CuentaCorriente():
	def __init__(self, saldo=0):
		self.saldo = saldo

	def depositar(self, monto):
		self.saldo += monto

	def retirar(self, monto):
		if monto > self.saldo:
			print("El monto solicitado excede a su saldo actual")
			return False
		
		self.saldo -= monto
		return True

	def transferir(self, cuenta, monto):
		if self.retirar(monto):
			cuenta.depositar(monto)




