def quick(lista):
	if lista:
		primer = lista[0]
		izq = [_ for _ in lista if _ < primer]
		der = [_ for _ in lista if _ > primer]
		return quick(izq) + [primer] + quick(der)
	return []

print(quick([7 , 2 , 3, 9 , 8, 5 , 4]))