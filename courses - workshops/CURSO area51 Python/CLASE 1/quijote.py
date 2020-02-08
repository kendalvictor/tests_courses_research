def contar(letra, letras):
	if letra not in letras:
		letras[letra] = 1
	else:
		letras[letra] += 1


with open("quijote.txt", "r") as archivo:
	leido = archivo.read().lower().replace(" ", "")

	letras = {}
	for letra in leido:
		if letra.isalpha():	
			contar(letra, letras)		
	del leido

	lista_ordenada = sorted(letras.items(), key=lambda t: t[1])
	del letras
	del lista_ordenada[:-1]

	print('La letra "{0}" es la que mas se repite, {1} veces'.format(
		lista_ordenada[-1][0], lista_ordenada[-1][1]))
	

