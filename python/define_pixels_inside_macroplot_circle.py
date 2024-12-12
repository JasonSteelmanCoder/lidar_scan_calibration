import matplotlib.pyplot as plt
import numpy as np

radius = 10

x = np.linspace(0, radius)
y = np.sqrt(radius**2 - x**2)
plt.plot(x, y)
for xi in range(1, 11):
    for yi in range(1, 11):
        if yi <= np.sqrt(radius**2 - xi**2):
            print(xi, yi)
            plt.plot(xi, yi, 'o')
plt.xlim(left=0)
plt.axis('equal')
plt.show()
