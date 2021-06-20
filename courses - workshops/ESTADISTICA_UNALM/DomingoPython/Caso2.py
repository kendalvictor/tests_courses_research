##Introducción a pandas
import pandas as pd
x = pd.Series([1,5,8,6,-9])
x = pd.Series([1,5,8,6,-9], index =["q","w","e","t","g"])
x["w"]
x[["w","e"]]
x.index
sorted(x.index)
x.reindex(sorted(x.index))
y = pd.Series([11,15,18,16,-9], index =["t","m","q","w","e"])
x + y

edades = {"Juan":19,"Jim":21, "María":27, "Juana":22}
x = pd.Series(edades)

agenda = {"nombre": ["Alicia","Beatriz","Juan","Sonia"],"distrito":["SJM","LV","LM","S"],"edad":[29,31,25,26],"peso":[59,61,57,36],"sexo":["F","F","M","F"]}
x = pd.DataFrame(agenda, columns = ["nombre","distrito","edad","peso","sexo"])
x.nombre
x["nombre"]
###Estadísticas descriptivas:
x.describe()
x.describe(include="all")
x.median()
x.groupby("sexo")['edad'].median()
x.groupby("sexo")['edad'].std()

##CASO 2:
import pandas as pd
import numpy as np
whiskies = pd.read_csv("whiskies.txt")
whiskies.head()
whiskies.tail()
regiones = pd.read_csv("regions.txt")
whiskies["Region"] = regiones
#whiskies["Region"] = pd.read_csv("regions.txt")

whiskies.columns
whiskies.iloc[5]
whiskies.iloc[2:10,]
sabores = whiskies.iloc[:,2:14]

##Correlaciones entre sabores
corr_sabores = pd.DataFrame.corr(sabores)

import matplotlib.pyplot as plt
plt.figure(figsize=[10,10])
plt.pcolor(corr_sabores)
plt.colorbar()
plt.savefig("Correlación Sabores")
plt.show()


##Correlaciones entre destilerías
corr_destilerias = pd.DataFrame.corr(sabores.transpose())
plt.figure(figsize=[10,10])
plt.pcolor(corr_destilerias)
plt.colorbar()
plt.savefig("Correlación Destilerías")
plt.show()

##matriz de correlaciones entre destilerías:
whiskies = whiskies.reset_index(drop=True)
pd.DataFrame.corr(whiskies.iloc[:,2:14].transpose())

