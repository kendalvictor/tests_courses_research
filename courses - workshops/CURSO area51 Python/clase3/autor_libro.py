class Autor():
	def __init__(self, nombre, anno):
		self.nombre = nombre
		self.anno = anno
		self.list_libro = []

	def _agregar_libro(self, libro):
		if libro not in self.list_libro:
			self.list_libro.append(libro)
		else:
			print("El libro ya fue agregado")

	def agregar_libro(self, *args, **kwargs):
		if args.__len__() == 1:
			libro = args[0]
			self._agregar_libro(libro)
		else:
			libro = Libro(**kwargs)
			self._agregar_libro(libro)

class Libro():
	def __init__(self, titulo, anno):
		self.titulo = titulo
		self.anno = anno

	def __eq__(self, other):
		return self.titulo == other.titulo and self.anno = other.anno
