import matplotlib.pyplot as plt
import numpy as np
import os
import json
import ast

output_location = f'C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/pixel_dimensions.json'
radius = 10
pixel_width = 1.0

x = np.linspace(0, radius)
y = np.sqrt(radius**2 - x**2)
plt.plot(x, y)
quad1_corners = []
quad2_corners = []
quad3_corners = []
quad4_corners = []
for xi in np.arange(pixel_width, 11, pixel_width):
    for yi in np.arange(pixel_width, 11, pixel_width):
        if yi <= np.sqrt(radius**2 - xi**2):
            quad1_corners.append((xi, yi))
            quad2_corners.append((-xi, yi))
            quad3_corners.append((-xi, -yi))
            quad4_corners.append((xi, -yi))
            plt.plot(xi, yi, 'bo')
# print(quad1_corners[0])
# print(quad2_corners[0])
# print(quad3_corners[0])
# print(quad4_corners)
# plt.xlim(left=0)
# plt.axis('equal')
# plt.show()

pixels = []

for corner in quad1_corners[1:]:        # the [1:] slice excludes the pixel closest to the center, since that one has part of the donut hole cutting through it.
    top_right_x = corner[0]
    top_right_y = corner[1]
    top_left_x = top_right_x - pixel_width
    top_left_y = top_right_y
    bottom_left_x = top_left_x
    bottom_left_y = top_right_y - pixel_width
    bottom_right_x = top_right_x
    bottom_right_y = bottom_left_y

    pixel = (
        (top_right_x, top_right_y), 
        (top_left_x, top_left_y),
        (bottom_left_x, bottom_left_y),
        (bottom_right_x, bottom_right_y)
    )
    pixels.append(pixel)


for corner in quad2_corners[1:]:
    top_left_x = corner[0]
    top_left_y = corner[1]
    bottom_left_x = top_left_x
    bottom_left_y = top_left_y - pixel_width
    bottom_right_x = bottom_left_x + pixel_width
    bottom_right_y = bottom_left_y
    top_right_x = top_left_x + pixel_width
    top_right_y = top_left_y

    pixel = (
        (top_right_x, top_right_y), 
        (top_left_x, top_left_y),
        (bottom_left_x, bottom_left_y),
        (bottom_right_x, bottom_right_y)
    )
    pixels.append(pixel)


for corner in quad3_corners[1:]:
    bottom_left_x = corner[0]
    bottom_left_y = corner[1]
    bottom_right_x = bottom_left_x + pixel_width
    bottom_right_y = bottom_left_y
    top_right_x = bottom_right_x
    top_right_y = bottom_left_y + pixel_width
    top_left_x = bottom_left_x
    top_left_y = top_right_y

    pixel = (
        (top_right_x, top_right_y), 
        (top_left_x, top_left_y),
        (bottom_left_x, bottom_left_y),
        (bottom_right_x, bottom_right_y)
    )
    pixels.append(pixel)


for corner in quad4_corners[1:]:
    bottom_right_x = corner[0]
    bottom_right_y = corner[1]
    top_right_x = bottom_right_x
    top_right_y = bottom_right_y + pixel_width
    top_left_x = bottom_right_x - pixel_width
    top_left_y = bottom_right_y + pixel_width
    bottom_left_x = top_left_x
    bottom_left_y = bottom_right_y

    pixel = (
        (top_right_x, top_right_y), 
        (top_left_x, top_left_y),
        (bottom_left_x, bottom_left_y),
        (bottom_right_x, bottom_right_y)
    )
    pixels.append(pixel)

dimensions = {}

for i in range(len(pixels)):
    x1 = pixels[i][0][0]        # right
    y1 = pixels[i][0][1]        # top
    x2 = pixels[i][2][0]        # left
    y2 = pixels[i][2][1]        # bottom
    dimension = [x1, y1, x2, y2]
    centerpoint = [x2 + (0.5 * pixel_width), y2 + (0.5 * pixel_width)]      # the center point is: the left edge plus half of a pixel, the bottom edge plus half of a pixel
    dimensions[str(i)] = {"right_top_left_bottom": dimension, "centerpoint": centerpoint}

# print(dimensions)


## uncomment to see a visualization of the pixels and their centers
# for value in dimensions.values():
#     pixel = value["right_top_left_bottom"]
#     xs = [pixel[2], pixel[0], pixel[0], pixel[2], pixel[2]]
#     ys = [pixel[3], pixel[3], pixel[1], pixel[1], pixel[3]]
#     plt.plot(xs, ys)
#     center = value["centerpoint"]
#     plt.scatter(center[0], center[1])
# plt.axis('equal')
# plt.show()


## uncomment to save to file
with open(output_location, 'w') as output_file:
    json.dump(dimensions, output_file)
