import math
import matplotlib.pyplot as plt
import re
import numpy as np

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

point_names = [
    "e2",
    "e2.5",
    "e5",
    "n2",
    "n2.5",
    "n5",
    "ne3",
    "ne4",
    "ne6",
    "nw3",
    "nw4",
    "nw6",
    "s2",
    "s2.5",
    "s5",
    "se3",
    "se4",
    "se6",
    "sw3",
    "sw4",
    "sw6",
    "w2",
    "w2.5",
    "w5"
]

new_macroplot = {}
new_xs = []
new_ys = []
inner_wall_xs = []
inner_wall_ys = []
outer_wall_xs = []
outer_wall_ys = []
right_wall_xs = []
right_wall_ys = []
left_wall_xs = []
left_wall_ys = []

for i in range(24):
    point = coordinate_pairs[i]

    old_x = point[0]
    old_y = point[1]

    # find locations of the clip plot's original walls
    distance_from_origin = np.sqrt(old_x**2 + old_y**2)
    
    inner_wall_distance = distance_from_origin - 0.25
    inner_wall_scaling_factor = inner_wall_distance / distance_from_origin
    old_inner_wall_x = old_x * inner_wall_scaling_factor
    old_inner_wall_y = old_y * inner_wall_scaling_factor

    outer_wall_distance = distance_from_origin + 0.25
    outer_wall_scaling_factor = outer_wall_distance / distance_from_origin
    old_outer_wall_x = old_x * outer_wall_scaling_factor
    old_outer_wall_y = old_y * outer_wall_scaling_factor

    quarter_unit_vector_x = (old_x / distance_from_origin) / 4
    quarter_unit_vector_y = (old_y / distance_from_origin) / 4

    old_right_wall_x = old_x + quarter_unit_vector_y
    old_right_wall_y = old_y - quarter_unit_vector_x
    old_left_wall_x = old_x - quarter_unit_vector_y
    old_left_wall_y = old_y + quarter_unit_vector_x

    # rotate the points to their new coordinates
    row1 = a * old_x + b * old_y
    row2 = c * old_x + d * old_y
    new_point = (row1, row2)

    # rotate the walls to their new coordinates
    inner_wall_x = a * old_inner_wall_x + b * old_inner_wall_y
    inner_wall_y = c * old_inner_wall_x + d * old_inner_wall_y

    outer_wall_x = a * old_outer_wall_x + b * old_outer_wall_y
    outer_wall_y = c * old_outer_wall_x + d * old_outer_wall_y

    right_wall_x = a * old_right_wall_x + b * old_right_wall_y
    right_wall_y = c * old_right_wall_x + d * old_right_wall_y

    left_wall_x = a * old_left_wall_x + b * old_left_wall_y
    left_wall_y = c * old_left_wall_x + d * old_left_wall_y

    # store all the information about the new clip plot in an object
    new_macroplot[point_names[i]] = {
        "name": point_names[i],
        "x": row1,
        "y": row2,
        "inner_wall_x": inner_wall_x,
        "inner_wall_y": inner_wall_y,
        "outer_wall_x": outer_wall_x,
        "outer_wall_y": outer_wall_y,
        "right_wall_x": right_wall_x,
        "right_wall_y": right_wall_y,
        "left_wall_x": left_wall_x,
        "left_wall_y": left_wall_y
    }

    # put the locations into lists for plotting
    new_xs.append(row1)
    new_ys.append(row2)
    inner_wall_xs.append(inner_wall_x)
    inner_wall_ys.append(inner_wall_y)
    outer_wall_xs.append(outer_wall_x)
    outer_wall_ys.append(outer_wall_y)
    right_wall_xs.append(right_wall_x)
    right_wall_ys.append(right_wall_y)
    left_wall_xs.append(left_wall_x)
    left_wall_ys.append(left_wall_y)

for value in new_macroplot.values():
    print(value)

plt.scatter(new_xs, new_ys)
plt.scatter(inner_wall_xs, inner_wall_ys, color='orange', alpha=0.33)
plt.scatter(outer_wall_xs, outer_wall_ys, color='orange', alpha=0.33)
plt.scatter(right_wall_xs, right_wall_ys, color='purple', alpha=0.33)
plt.scatter(left_wall_xs, left_wall_ys, color='green', alpha=0.33)
plt.axis('equal')
plt.show()
