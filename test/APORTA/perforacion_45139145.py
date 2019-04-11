def i_perforacion(v1, v2):
    # Validacion input
    if not(isinstance(v1, list) and isinstance(v2, list)):
        return 'Parametros incorrectos'
    
    if not(v1 and v2):
        return 'Contenido nulo detectado'
    
    if len(v1) != len(v2):
        return 'Ingrese listas de igual dimension'
    
    # Obtencion de intervalos
    intervalos = {
        (v1[i], v2[i]) for i in range(len(v1))
    }
    
    #Ordeno de izq -> der
    intervalos = sorted(
        intervalos, key=lambda _:_[0]
    )
    
    # Regla de interseccion
    regla_interseccion = lambda a, b: a[1] >= b[0]
    
    anteriores = [intervalos[0]]
    cardinales = []
    
    # Borrador Flujo
    for inter in intervalos[1:]:
        # Valido interseccion con los intervalos de punto inicial menor al actual
        validacion = all([regla_interseccion(ant, inter) for ant in anteriores])
        
        # Al fallar la validacion reinicio los anteriores y es necesario un punto mas
        if not validacion:
            cardinales.append(anteriores[-1][0])
            anteriores = []
        
        anteriores.append(inter)
    
    # Casos especificos
    if cardinales:
        cardinales.append(inter[0])
    else:
        cardinales.append(intervalos[-1][0])
        
    return cardinales

if __name__ == "__main__":
    v1 = [1, 3, 5, 7, 2, 4, 11, 11]
    v2 = [4, 6, 10, 9, 6, 12, 15, 16]

    print(i_perforacion(v1, v2))