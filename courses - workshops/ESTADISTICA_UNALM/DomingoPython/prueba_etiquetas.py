import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import numpy as np 

def update_ticks(x, pos):
    if x == 0:
        return 'Mean'
    elif pos == 6:
        return 'pos is 6'
    else:
        return x

data = np.random.normal(0, 1, 1000)
fig, ax = plt.subplots()
ax.hist(data, bins=25, edgecolor='black')
ax.xaxis.set_major_formatter(mticker.FuncFormatter(update_ticks))
plt.show()
