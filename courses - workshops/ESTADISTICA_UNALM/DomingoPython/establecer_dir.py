Python 3.6.4 (v3.6.4:d48eceb, Dec 19 2017, 06:54:40) [MSC v.1900 64 bit (AMD64)] on win32
Type "copyright", "credits" or "license()" for more information.
>>> import numpy
Traceback (most recent call last):
  File "<pyshell#0>", line 1, in <module>
    import numpy
ModuleNotFoundError: No module named 'numpy'
>>> import numpy
Traceback (most recent call last):
  File "<pyshell#1>", line 1, in <module>
    import numpy
ModuleNotFoundError: No module named 'numpy'
>>> import numpy
>>> 
========= RESTART: C:\Users\Alumno08\Desktop\DomingoPython\Caso1.py =========
>>> 
========= RESTART: C:\Users\Alumno08\Desktop\DomingoPython\Caso2.py =========
>>> 
=== RESTART: C:\Users\Alumno08\Desktop\DomingoPython\EjemploMatplotlib.py ===

Warning (from warnings module):
  File "C:\Users\Alumno08\AppData\Local\Programs\Python\Python36\lib\site-packages\matplotlib\axes\_base.py", line 3157
    'Attempted to set non-positive xlimits for log-scale axis; '
UserWarning: Attempted to set non-positive xlimits for log-scale axis; invalid limits will be ignored.

Warning (from warnings module):
  File "C:\Users\Alumno08\AppData\Local\Programs\Python\Python36\lib\site-packages\matplotlib\axes\_base.py", line 3477
    'Attempted to set non-positive ylimits for log-scale axis; '
UserWarning: Attempted to set non-positive ylimits for log-scale axis; invalid limits will be ignored.
>>> 
=== RESTART: C:\Users\Alumno08\Desktop\DomingoPython\EjemploMatplotlib2.py ===
>>> 
=============================== RESTART: Shell ===============================
>>> import numpy as np
>>> import matplotlib.pyplot as plt
>>> fig=plt.figure()
>>> ax=plt.axes()
>>> x=np.linspace(0,10,20)
>>> x
array([ 0.        ,  0.52631579,  1.05263158,  1.57894737,  2.10526316,
        2.63157895,  3.15789474,  3.68421053,  4.21052632,  4.73684211,
        5.26315789,  5.78947368,  6.31578947,  6.84210526,  7.36842105,
        7.89473684,  8.42105263,  8.94736842,  9.47368421, 10.        ])
>>> y=x**2
>>> plt.plot(x,y)
[<matplotlib.lines.Line2D object at 0x000000394E4C7D30>]
>>> fig
<Figure size 640x480 with 1 Axes>
>>> plt.show()
>>> x=np.array([1,2,3,4,5,6])
>>> y=x*x
>>> plt.plot(x,y)
[<matplotlib.lines.Line2D object at 0x00000039507DD438>]
>>> fig.show()
Traceback (most recent call last):
  File "<pyshell#16>", line 1, in <module>
    fig.show()
  File "C:\Users\Alumno08\AppData\Local\Programs\Python\Python36\lib\site-packages\matplotlib\figure.py", line 450, in show
    manager.show()
  File "C:\Users\Alumno08\AppData\Local\Programs\Python\Python36\lib\site-packages\matplotlib\backends\_backend_tk.py", line 551, in show
    self.canvas.manager.window.attributes('-topmost', 1)
AttributeError: 'NoneType' object has no attribute 'attributes'
>>> Exception in Tkinter callback
Traceback (most recent call last):
  File "C:\Users\Alumno08\AppData\Local\Programs\Python\Python36\lib\site-packages\matplotlib\backends\tkagg.py", line 26, in blit
    dataptr, colormode, bboxptr)
_tkinter.TclError: this isn't a Tk application

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "C:\Users\Alumno08\AppData\Local\Programs\Python\Python36\lib\tkinter\__init__.py", line 1699, in __call__
    return self.func(*args)
  File "C:\Users\Alumno08\AppData\Local\Programs\Python\Python36\lib\tkinter\__init__.py", line 745, in callit
    func(*args)
  File "C:\Users\Alumno08\AppData\Local\Programs\Python\Python36\lib\site-packages\matplotlib\backends\_backend_tk.py", line 310, in idle_draw
    self.draw()
  File "C:\Users\Alumno08\AppData\Local\Programs\Python\Python36\lib\site-packages\matplotlib\backends\backend_tkagg.py", line 13, in draw
    tkagg.blit(self._tkphoto, self.renderer._renderer, colormode=2)
  File "C:\Users\Alumno08\AppData\Local\Programs\Python\Python36\lib\site-packages\matplotlib\backends\tkagg.py", line 34, in blit
    dataptr, colormode, bboxptr)
_tkinter.TclError: this isn't a Tk application

>>> plt.show()
>>> x
array([1, 2, 3, 4, 5, 6])
>>> x = np.linspace(0,10,20)
>>> x
array([ 0.        ,  0.52631579,  1.05263158,  1.57894737,  2.10526316,
        2.63157895,  3.15789474,  3.68421053,  4.21052632,  4.73684211,
        5.26315789,  5.78947368,  6.31578947,  6.84210526,  7.36842105,
        7.89473684,  8.42105263,  8.94736842,  9.47368421, 10.        ])
>>> plt.plot(x)
[<matplotlib.lines.Line2D object at 0x00000039508E7DD8>]
>>> plt.show()
>>> x
array([ 0.        ,  0.52631579,  1.05263158,  1.57894737,  2.10526316,
        2.63157895,  3.15789474,  3.68421053,  4.21052632,  4.73684211,
        5.26315789,  5.78947368,  6.31578947,  6.84210526,  7.36842105,
        7.89473684,  8.42105263,  8.94736842,  9.47368421, 10.        ])
>>> plt.plot(x, np.sin(x))
[<matplotlib.lines.Line2D object at 0x0000003950F71048>]
>>> plt.show()
>>> plt.plot(x, np.cos(x))
[<matplotlib.lines.Line2D object at 0x0000003950EFE4A8>]
>>> plt.show()
>>> plt.plot(x, np.sin(x), color='blue',linestyle='solid')
[<matplotlib.lines.Line2D object at 0x0000003950FED898>]
>>> plt.show()
>>> plt.plot(x, np.sin(x-1), color='#FFDD44',linestyle=':')
[<matplotlib.lines.Line2D object at 0x000000395121CA20>]
>>> plt.show()
>>> plt.savefig('grafico1.pdf')
>>> import pandas as pd





