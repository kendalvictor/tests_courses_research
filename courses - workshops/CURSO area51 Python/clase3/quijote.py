# -*- coding: utf-8 -*-
from unicodedata import normalize, category
from random import choice

def clean_phrase(word):
    return ''.join((_ for _ in normalize('NFD', word) if category(_) == 'Ll'))

def mas_repetido(lista):
	contador = [lista.count(_) for _ in lista]


with open("quijote.txt", "r") as archivo:
	palabras = {}
	leido = archivo.read().lower()
	lista = [clean_phrase(_) for _ in leido.split() if clean_phrase(_)]

	for indice, palab in enumerate(lista[:-1]):
		if palab not in palabras:
			palabras[palab] = []

		palabras[palab].append(
			clean_phrase(lista[indice + 1])
		)

	lista_ordenada = sorted(palabras.items(), key=lambda t: len(t[1]))
	for k, v in lista_ordenada:
		print(k, len(v))
	
	oracion = []
	for _ in range(10):
		palab = choice(lista[:-1])
		oracion.append(choice(palabras[palab]))
	print(oracion)









