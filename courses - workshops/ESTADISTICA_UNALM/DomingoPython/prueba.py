Python 3.6.4 (v3.6.4:d48eceb, Dec 19 2017, 06:54:40) [MSC v.1900 64 bit (AMD64)] on win32
Type "copyright", "credits" or "license()" for more information.
>>> import numpy as np
>>> import matplotlib.pyplot as plt
>>> 
>>> x = np.array([1,2,3,4,5,6])
>>> y = x*x
>>> plt.plot(x,y)
[<matplotlib.lines.Line2D object at 0x000000F3AA22DE80>]
>>> plt.show()
>>> x = np.linspace(0,10,20)
>>> x
array([ 0.        ,  0.52631579,  1.05263158,  1.57894737,  2.10526316,
        2.63157895,  3.15789474,  3.68421053,  4.21052632,  4.73684211,
        5.26315789,  5.78947368,  6.31578947,  6.84210526,  7.36842105,
        7.89473684,  8.42105263,  8.94736842,  9.47368421, 10.        ])
>>> fig = plt.figure()
>>> ax = plt.axes()
>>> x = np.linspace(0,10,20)
>>> y = x**2
>>> plt.plot(x,y)
[<matplotlib.lines.Line2D object at 0x000000F3A7EE70F0>]
>>> plt.savefig("gráfico1.pdf")
>>> plt.show()
>>> dir(plt.plot)
['__annotations__', '__call__', '__class__', '__closure__', '__code__', '__defaults__', '__delattr__', '__dict__', '__dir__', '__doc__', '__eq__', '__format__', '__ge__', '__get__', '__getattribute__', '__globals__', '__gt__', '__hash__', '__init__', '__init_subclass__', '__kwdefaults__', '__le__', '__lt__', '__module__', '__name__', '__ne__', '__new__', '__qualname__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__']
>>> 
