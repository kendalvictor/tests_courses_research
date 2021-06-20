x = [1,2,3,4,5,8,9]

class MiLista(list):
    def remover_min(self):
        self.remove(min(self))
    def remover_max(self):
        self.remove(min(self))
        
y = MiLista(x)
dir(x)
dir(y)
    

class Persona:
    def __init__(self, nombre, dni, edad):
        self.nombre = nombre
        self.dni = dni
        self.edad = edad

    def iniciales(self):
        cadena = ''
        for caracter in self.nombre:
            if caracter >= 'A' and caracter <= 'Z':
                cadena = cadena + caracter + '. '
        return cadena

    
Juan = Persona("Juan López", "97586012", 21)
