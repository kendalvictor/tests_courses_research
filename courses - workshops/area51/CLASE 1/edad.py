def get_num():
    num = 0
    try:
        num = int(input("Ingrese año de nacimiento: "))
    except ValueError:
        print("ERROR año no valido, ", end=" /")
        num = get_num()
    except Exception as e:
        raise Exception(str(e))
    return num


anno = get_num()
print("""
	Tu edad es: {0}
""".format(2017 - anno))



