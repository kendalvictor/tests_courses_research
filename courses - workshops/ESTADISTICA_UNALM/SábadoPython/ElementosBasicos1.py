## Objetos, instancia, atributos y métodos
import numpy as np
x = np.array([1,3,5])
x.mean()  ## función o método del objeto x
x.shape ##atributo del objeto x

## Módulos y métodos
import math
math.pi
math.sqrt(10)
math.sin(math.pi/2)

from math import pi  ## importa solo el valor de pi desde el módulo math

import math
import numpy as np
math.sqrt
np.sqrt
math.sqrt(2)
np.sqrt(2)
math.sqrt([1,3,5])
np.sqrt([1,3,5])

nombre = 'Ana'
type(nombre)  ##indica el tipo de objeto
dir(nombre) ##lista el conjunto de métodos disponibles para este objeto
dir(str) ##lista el conjunto de métodos disponibles para objetos de este tipo

help(nombre.upper) ##Para solicitar información o ayuda sobre los métodos:
nombre.upper()## Ejecuta el método upper asociado al objeto nombre
help(nombre.upper())##Solicita ayuda al resultado del método uper asociado al objeto

##Operaciones aritméticas

123 + 80
123 * 34
123 ** 34 ##potencia
123 ** 346
123 / 346
346 // 123  ##división entera

##Para obtener el factorial de un número:
import math
math.factorial(6)

##Para elegir un elemento al azar de un lista
import random
random.choice([10,33,51,12,45,90])
random.choice(["a","b","c","d","e","f"])

##Expresiones booleanas
type(True)
type(False)
False or True
not True or False
True and True
2 < 5
2 <= 8
2 == 8
2 != 8
[1,3,5] == [1,3,5]
[1,3,5] != [1,3,5]

[1,3,5] is [1,3,5]
[1,3,5] is not [1,3,5]

2.0 == 2.0
2.0 is 2.0
2.0 == 2
2 is not 2.0
