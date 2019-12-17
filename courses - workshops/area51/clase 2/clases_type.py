Carro = type('Carro', tuple(), {"saludar": lambda x: 'sube'})
Casa = type('Casa', tuple(), {"saludar": lambda x: 'entra'})
Carrocasa = type('Carrocasa', (Carro, Casa), {"a": lambda x: 'hola'})

bmw = Carrocasa()
print(bmw.saludar())

