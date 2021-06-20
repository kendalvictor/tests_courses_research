import numpy as np
import matplotlib.pyplot as plt
#import random
##plt.plot([0,1,4,9,16]);
##plt.show()

##Figura con una sola línea
fig = plt.figure()
ax = plt.axes()
x = np.linspace(0,10,20)
y = x**2
plt.plot(x,y)


##Una figura con múltiples líneas
plt.plot(x, np.sin(x))
plt.plot(x, np.cos(x))

##Ajustando colores y estilos:
plt.plot(x, np.sin(x), color='blue',linestyle='solid') 
plt.plot(x, np.sin(x-1), color='#FFDD44',linestyle=':')
plt.plot(x, np.sin(x-2), '--c')

x = np.linspace(0,10,20)
y1 = x**2
y2 = x**1.5
plt.plot(x,y1, "bo-", linewidth=2, markersize=4, label="y1")
plt.plot(x,y2, "gs-", linewidth=2, markersize=4, label="y2")
plt.xlabel("X")
plt.ylabel("Y")
plt.axis([-0.5,10.5,-5,105])
plt.legend(loc="upper left")
plt.savefig("myplot.pdf")
plt.show()

## ploteo usando escala logarítmica:
x = np.logspace(-1,1,40)
y1 = x**2
y2 = x**1.5
plt.loglog(x,y1, "bo-", linewidth=2, markersize=4, label="y1")
plt.loglog(x,y2, "gs-", linewidth=2, markersize=4, label="y2")
plt.xlabel("X")
plt.ylabel("Y")
plt.axis([-0.5,10.5,-5,105])
plt.legend(loc="upper left")
plt.show()
plt.savefig("myplot.png")

##Generando un histograma
x = np.random.normal(size=1000) #genera 1000 números aleatorios tomados de una normal estándar
plt.hist(x,density=True, bins=np.linspace(-5,5,21))
plt.show()

##Generando un gráfico de dispersión:
rng = np.random.RandomState(0)
x = rng.randn(100)
y = rng.randn(100)
colors = rng.rand(100)
sizes = 1000 * rng.rand(100)
plt.scatter(x, y, c=colors, s=sizes, alpha=0.3, cmap='viridis')
plt.colorbar();
plt.savefig("myplot2")
