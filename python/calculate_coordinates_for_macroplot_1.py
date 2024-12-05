import math
import matplotlib.pyplot as plt

degrees_rotation = 104.8
rotation_angle = degrees_rotation * (math.pi / 180)      # in radians

a = math.cos(rotation_angle)
b = -1 * math.sin(rotation_angle)
c = math.sin(rotation_angle)
d = math.cos(rotation_angle)

rotation_matrix = [a, b, c, d]

coordinate_pairs = [
(2,0),
(2.5,0),
(5,0),
(0,2),
(0,2.5),
(0,5),
(2.12132034,2.12132034),
(2.82842712,2.82842712),
(4.24264068,4.24264068),
(-2.12132034,2.12132034),
(-2.82842712,2.82842712),
(-4.24264068,4.24264068),
(0,-2),
(0,-2.5),
(0,-5),
(2.12132034,-2.12132034),
(2.82842712,-2.82842712),
(4.24264068,-4.24264068),
(-2.12132034,-2.12132034),
(-2.82842712,-2.82842712),
(-4.24264068,-4.24264068),
(-2,0),
(-2.5,0),
(-5,0),
]

new_coordinates = []
new_xs = []
new_ys = []

for point in coordinate_pairs:
    row1 = a * point[0] + b * point[1]
    row2 = c * point[0] + d * point[1]
    new_point = (row1, row2)
    new_coordinates.append(new_point)
    new_xs.append(row1)
    new_ys.append(row2)

print(new_coordinates)

plt.scatter(new_xs, new_ys)
plt.axis('equal')
plt.show()
