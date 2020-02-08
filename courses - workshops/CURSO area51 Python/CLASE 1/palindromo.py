ingreso = input("Ingresa una palabra o numero: ")

if ingreso == ingreso[::-1]:
	print("SI", end=" ")
else:
	print("NO", end=" ")

print("es palindromo")
