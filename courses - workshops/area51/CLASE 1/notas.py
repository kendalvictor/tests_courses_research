def get_num(i):
    num = 0
    try:
        num = int(input("Ingrese {1} {0}: ".format(
        	i if i else "", "nota" if i else "cantidad de cursos"
        )))
    except ValueError:
        print("ERROR {0} no valida, ".format(
        	"nota" if i else "cantidad"), end=" /")
        num = get_num(i)
    except Exception as e:
        raise Exception(str(e))
    return num

nn = get_num("")

notas = []
for i in range(1, nn + 1):
	nota = get_num(i)
	notas.append(nota)

print("""
	Tu promedio es: {0}
""".format(round(sum(notas) / nn, 2)))
