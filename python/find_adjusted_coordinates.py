# this program works like demonstrate_coordinate_system.py, except that it adds 0.25 meters to each of the distances from center, 
# to account for the measurements being to the edge of the clip plot, instead of the center of the clip plot.

# Here is a visual demonstration of how the coordinate system works to locate the clip plots within the macroplot
import matplotlib.pyplot as plt
import numpy as np

# the the coordinates of the clip plot edges
coordinate_pairs = [
(2,0),
(2,0),
(2.5,0),
(2.5,0),
(5,0),
(5,0),
(0,2),
(0,2),
(0,2.5),
(0,2.5),
(0,5),
(0,5),
(2.12132034,2.12132034),
(2.12132034,2.12132034),
(2.82842712,2.82842712),
(2.82842712,2.82842712),
(4.24264068,4.24264068),
(4.24264068,4.24264068),
(-2.12132034,2.12132034),
(-2.12132034,2.12132034),
(-2.82842712,2.82842712),
(-2.82842712,2.82842712),
(-4.24264068,4.24264068),
(-4.24264068,4.24264068),
(0,-2),
(0,-2),
(0,-2.5),
(0,-2.5),
(0,-5),
(0,-5),
(2.12132034,-2.12132034),
(2.12132034,-2.12132034),
(2.82842712,-2.82842712),
(2.82842712,-2.82842712),
(4.24264068,-4.24264068),
(4.24264068,-4.24264068),
(-2.12132034,-2.12132034),
(-2.12132034,-2.12132034),
(-2.82842712,-2.82842712),
(-2.82842712,-2.82842712),
(-4.24264068,-4.24264068),
(-4.24264068,-4.24264068),
(-2,0),
(-2,0),
(-2.5,0),
(-2.5,0),
(-5,0),
(-5,0)
]

new_coords = []

for pair in coordinate_pairs:
    magnitude = np.sqrt(pair[0]**2 + pair[1]**2)
    multiples_of_a_quarter = magnitude / 0.25
    quarter_x = pair[0] / multiples_of_a_quarter
    quarter_y = pair[1] / multiples_of_a_quarter
    new_x = pair[0] + quarter_x
    new_y = pair[1] + quarter_y 
    new_coords.append((new_x, new_y))

# plot the coordinates to show the layout of the macroplot
# x_coords, y_coords = zip(*coordinate_pairs)
# plt.scatter(x_coords, y_coords)
# new_x_coords, new_y_coords = zip(*new_coords)
# plt.scatter(new_x_coords, new_y_coords)
# plt.axis('equal')
# plt.show()

print(new_coords)
