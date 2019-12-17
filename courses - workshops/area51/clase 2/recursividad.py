
def draw_tri(n, veces=1):
	print("*"*veces)
	draw_tri(n - 1, veces=veces + 1) if n > 0 else 1
	print("*"*veces)

draw_tri(6)

