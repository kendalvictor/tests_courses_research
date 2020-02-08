import requests

r = requests.get('https://api.fixer.io/latest').json()

def get_num():
    num = 0
    try:
        num = float(input("Ingrese euros a convertir: "))
    except ValueError:
        print("ERROR entero no valido, ", end=" /")
        num = get_num(i)
    except Exception as e:
        raise Exception(str(e))
    return num

dicc = {"USD": "Dolares"}
euros = get_num()
for moneda, valor in r["rates"].items():
	print(dicc[moneda] if moneda in dicc else moneda, " : ",
		round(euros*float(valor), 3))