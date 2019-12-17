from dis import dis

def comprension():
	return (_**2 for _ in range(100))

def mapeando():
	return map(lambda x: x**2, range(100))

dis(comprension)
print("///////")
dis(mapeando)

