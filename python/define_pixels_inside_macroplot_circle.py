import matplotlib.pyplot as plt
import numpy as np
import os
import json

output_location = f'C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/pixel_dimensions.json'
radius = 10
pixel_width = 0.5

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

for corner in quad1_corners:
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


for corner in quad2_corners:
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


for corner in quad3_corners:
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


for corner in quad4_corners:
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

dimensions = []

for i in range(len(pixels)):
    x1 = pixels[i][0][0]
    y1 = pixels[i][0][1]
    x2 = pixels[i][2][0]
    y2 = pixels[i][2][1]
    dimension = [x1, y1, x2, y2]
    dimensions.append(dimension)
    print(dimension)

with open(output_location, 'w') as output_file:
    json.dump(dimensions, output_file)


# print(len(pixels))

# for pixel in pixels:
#     xs = [pixel[0][0], pixel[1][0], pixel[2][0], pixel[3][0], pixel[0][0]]
#     ys = [pixel[0][1], pixel[1][1], pixel[2][1], pixel[3][1], pixel[0][1]]
#     plt.plot(xs, ys)
# plt.axis('equal')
# plt.show()

