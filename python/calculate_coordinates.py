# this program outputs the coordinates of clip plots, rotated to the coordinate system of the lidar scan that they belong to.
# this program has been adjusted for clip plot center

import os
import math
import matplotlib.pyplot as plt
import numpy as np
import json

## USER: put the path to your output folder here
## You will have to uncomment a section near the end of the script to actually save to the output to file 
output_path = f'C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration'

## these coordinates are based on the cardinal directions and the distances of the clip plots from macroplot center.
## they are not yet adjusted for clip plot center (which is 0.25 cm further from the origin)
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

## these are the names of the clip plots
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

## these are the degrees of rotation from the macroplot coordinates (where north is vertical up) to the lidar scan coordinates (where north is an arbitrary direction)
degrees_rotation = [104.8, -0.6, 134.2]

## loop through the macroplots
for i in range(3):

    ## set variables
    macroplot_num = str(i + 1)
    rotation_angle = degrees_rotation[i] * (math.pi / 180)      # in radians

    ## set variables to use in rotation matrices
    a = math.cos(rotation_angle)
    b = -1 * math.sin(rotation_angle)
    c = math.sin(rotation_angle)
    d = math.cos(rotation_angle)

    rotation_matrix = [a, b, c, d]

    outer_left_a = math.cos(45 * (math.pi / 180))
    outer_left_b = -1 * math.sin(45 * (math.pi / 180))
    outer_left_c = math.sin(45 * (math.pi / 180))
    outer_left_d = math.cos(45 * (math.pi / 180))

    inner_left_a = math.cos(135 * (math.pi / 180))
    inner_left_b = -1 * math.sin(135 * (math.pi / 180))
    inner_left_c = math.sin(135 * (math.pi / 180))
    inner_left_d = math.cos(135 * (math.pi / 180))

    inner_right_a = math.cos(225 * (math.pi / 180))
    inner_right_b = -1 * math.sin(225 * (math.pi / 180))
    inner_right_c = math.sin(225 * (math.pi / 180))
    inner_right_d = math.cos(225 * (math.pi / 180))

    outer_right_a = math.cos(315 * (math.pi / 180))
    outer_right_b = -1 * math.sin(315 * (math.pi / 180))
    outer_right_c = math.sin(315 * (math.pi / 180))
    outer_right_d = math.cos(315 * (math.pi / 180))

    ## set up empty data structures to be populated later
    new_macroplot = {}
    new_xs = []
    new_ys = []
    outer_left_xs = []
    outer_left_ys = []
    inner_left_xs = []
    inner_left_ys = []
    inner_right_xs = []
    inner_right_ys = []
    outer_right_xs = []
    outer_right_ys = []

    ## loop through the clip plots
    for i in range(24):

        ## grab the details of the current clip plot
        point = coordinate_pairs[i]

        nominal_old_x = point[0]
        nominal_old_y = point[1]

        # adjust coordinates for clip plot center instead of clip plot edge
        magnitude = np.sqrt(nominal_old_x**2 + nominal_old_y**2)
        multiples_of_quarter = magnitude / 0.25
        quarter_x = nominal_old_x / multiples_of_quarter
        quarter_y = nominal_old_y / multiples_of_quarter
        old_x = nominal_old_x + quarter_x
        old_y = nominal_old_y + quarter_y

        # find locations of the clip plot's original vertices
        distance_from_origin = np.sqrt(old_x**2 + old_y**2)

        scaling_factor = np.sqrt(0.125) / distance_from_origin      # scales the vector to the length of a clip plot diagonal from center to corner 
        old_tip_x = scaling_factor * old_x
        old_tip_y = scaling_factor * old_y
        
        # rotate vertices around the clip plot center (by rotating them about the origin, then translating them back by the vector)
        old_outer_left_x = outer_left_a * old_tip_x + outer_left_b * old_tip_y
        old_outer_left_y = outer_left_c * old_tip_x + outer_left_d * old_tip_y
        old_outer_left_x = old_outer_left_x + old_x
        old_outer_left_y = old_outer_left_y + old_y

        old_inner_left_x = inner_left_a * old_tip_x + inner_left_b * old_tip_y
        old_inner_left_y = inner_left_c * old_tip_x + inner_left_d * old_tip_y
        old_inner_left_x = old_inner_left_x + old_x
        old_inner_left_y = old_inner_left_y + old_y

        old_inner_right_x = inner_right_a * old_tip_x + inner_right_b * old_tip_y
        old_inner_right_y = inner_right_c * old_tip_x + inner_right_d * old_tip_y
        old_inner_right_x = old_inner_right_x + old_x
        old_inner_right_y = old_inner_right_y + old_y

        old_outer_right_x = outer_right_a * old_tip_x + outer_right_b * old_tip_y
        old_outer_right_y = outer_right_c * old_tip_x + outer_right_d * old_tip_y
        old_outer_right_x = old_outer_right_x + old_x
        old_outer_right_y = old_outer_right_y + old_y

        # rotate the points to their new coordinates
        row1 = a * old_x + b * old_y
        row2 = c * old_x + d * old_y
        new_point = (row1, row2)

        # rotate the vertices to their new coordinates
        outer_left_x = a * old_outer_left_x + b * old_outer_left_y
        outer_left_y = c * old_outer_left_x + d * old_outer_left_y

        inner_left_x = a * old_inner_left_x + b * old_inner_left_y
        inner_left_y = c * old_inner_left_x + d * old_inner_left_y

        inner_right_x = a * old_inner_right_x + b * old_inner_right_y
        inner_right_y = c * old_inner_right_x + d * old_inner_right_y

        outer_right_x = a * old_outer_right_x + b * old_outer_right_y
        outer_right_y = c * old_outer_right_x + d * old_outer_right_y

        # store all the information about the new clip plot in an object
        new_macroplot[point_names[i]] = {
            "name": point_names[i],
            "x": row1,
            "y": row2,
            "outer_left_x": outer_left_x,
            "outer_left_y": outer_left_y,
            "inner_left_x": inner_left_x,
            "inner_left_y": inner_left_y,
            "inner_right_x": inner_right_x,
            "inner_right_y": inner_right_y,
            "outer_right_x": outer_right_x,
            "outer_right_y": outer_right_y
        }

        # put the locations into lists for plotting
        new_xs.append(row1)
        new_ys.append(row2)
        outer_left_xs.append(outer_left_x)
        outer_left_ys.append(outer_left_y)

        inner_left_xs.append(inner_left_x)
        inner_left_ys.append(inner_left_y)

        inner_right_xs.append(inner_right_x)
        inner_right_ys.append(inner_right_y)

        outer_right_xs.append(outer_right_x)
        outer_right_ys.append(outer_right_y)

    for value in new_macroplot.values():
        print(value)

    ## uncomment to save the output to file
    # file_name = f'coordinates_macroplot{macroplot_num}'
    # output_location = os.path.join(output_path, f'{file_name}.json')
    # with open(output_location, 'w') as output:
    #     json.dump(new_macroplot, output)

    ## plot the output
    plt.scatter(new_xs, new_ys)
    plt.scatter(outer_left_xs, outer_left_ys, color='orange')
    plt.scatter(inner_left_xs, inner_left_ys, color='orange')
    plt.scatter(inner_right_xs, inner_right_ys, color='orange')
    plt.scatter(outer_right_xs, outer_right_ys, color='orange')
    plt.axis('equal')
    plt.show()
