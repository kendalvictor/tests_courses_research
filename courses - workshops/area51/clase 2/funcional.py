from functools import reduce

l = [1, 2 , 3, 4, 5]
c = map(lambda x: x**2, l)
print(list(c))
print("//////////////")
f = filter(lambda x: x < 5, l)
print(list(f))
print("//////////////")
r = reduce(lambda x,y: x*y, l)
print(r)

print("@@@@@@@@@@")
lc = (_**2 for _ in l if _ < 5)
print(lc)