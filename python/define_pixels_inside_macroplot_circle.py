import matplotlib.pyplot as plt
import numpy as np

radius = 10

x = np.linspace(0, radius)
y = np.sqrt(radius**2 - x**2)
plt.plot(x, y)
quad1_corners = []
quad2_corners = []
quad3_corners = []
quad4_corners = []
for xi in range(1, 11):
    for yi in range(1, 11):
        if yi <= np.sqrt(radius**2 - xi**2):
            quad1_corners.append((xi, yi))
            quad2_corners.append((-xi, yi))
            quad3_corners.append((-xi, -yi))
            quad4_corners.append((xi, -yi))
            plt.plot(xi, yi, 'bo')
plt.xlim(left=0)
plt.axis('equal')
# plt.show()
print(quad1_corners[-1])
print(quad2_corners[-1])
print(quad3_corners[-1])
print(quad4_corners[-1])