## This script finds the coordinates necessary to voxelize the circular lidar scan of a forest plot, while 
## excluding any pixels that overlap the inner or outer edges of the scan, and are therefore incomplete.
## The resulting coordinates are saved to a .json file. (To save them to file, you will need to uncomment a section at the end of the script.)
## There's also a section near the end that you can uncomment to view the arrangements of voxels in the macroplot

import matplotlib.pyplot as plt
import numpy as np
import os
import json

## USER: put the path to your output file here
output_location = f'C:/Users/{os.getenv("MS_USER_NAME")}/Desktop/lidar_scan_calibration/pixel_dimensions.json'
radius = 10
pixel_width = 1.0

## plot the outside of a quarter circle
x = np.linspace(0, radius)
y = np.sqrt(radius**2 - x**2)
plt.plot(x, y)

## create empty lists to populate with the coordinates of the outside corners of pixels
quad1_corners = []
quad2_corners = []
quad3_corners = []
quad4_corners = []

## find the outside corner of  each pixel that lands within the quarter circle
## then transpose it to all four quadrants
## and add the corners' coordinates to the correct list

## loop through x values that are within the macroplot radius at intervals of pixel-width
for xi in np.arange(pixel_width, 11, pixel_width):
    ## loop through y values that are within the macroplot radius at intervals of pixel-width
    for yi in np.arange(pixel_width, 11, pixel_width):
        ## check if they land inside of the quarter circle
        if yi <= np.sqrt(radius**2 - xi**2):
            ## if they are inside the circle, transpose them to the four quadrants and add them to the appropriate lise
            quad1_corners.append((xi, yi))
            quad2_corners.append((-xi, yi))
            quad3_corners.append((-xi, -yi))
            quad4_corners.append((xi, -yi))
            plt.plot(xi, yi, 'bo')

## uncomment to show a plot of the outer corners that are inside of the quarter circle
# print(quad1_corners[0])
# print(quad2_corners[0])
# print(quad3_corners[0])
# print(quad4_corners)
# plt.xlim(left=0)
# plt.axis('equal')
# plt.show()

## initialize an empty list to be populated by the loop
pixels = []

## loop through the corners of pixels in quadrant 1
for corner in quad1_corners[1:]:        # the [1:] slice excludes the pixel closest to the center, since that one has part of the donut hole cutting through it.
    
    ## find x and y of all four corners of the current pixel
    top_right_x = corner[0]
    top_right_y = corner[1]
    top_left_x = top_right_x - pixel_width
    top_left_y = top_right_y
    bottom_left_x = top_left_x
    bottom_left_y = top_right_y - pixel_width
    bottom_right_x = top_right_x
    bottom_right_y = bottom_left_y

    ## put the coordinates of all four corners together into one object
    pixel = (
        (top_right_x, top_right_y), 
        (top_left_x, top_left_y),
        (bottom_left_x, bottom_left_y),
        (bottom_right_x, bottom_right_y)
    )

    ## add the pixel object to the pixels list
    pixels.append(pixel)

## loop through the corners of pixels in quadrant 2
for corner in quad2_corners[1:]:

    ## find x and y of all four corners of the current pixel
    top_left_x = corner[0]
    top_left_y = corner[1]
    bottom_left_x = top_left_x
    bottom_left_y = top_left_y - pixel_width
    bottom_right_x = bottom_left_x + pixel_width
    bottom_right_y = bottom_left_y
    top_right_x = top_left_x + pixel_width
    top_right_y = top_left_y

    ## put the coordinates of all four corners together into one object
    pixel = (
        (top_right_x, top_right_y), 
        (top_left_x, top_left_y),
        (bottom_left_x, bottom_left_y),
        (bottom_right_x, bottom_right_y)
    )

    ## add the pixel object to the pixels list
    pixels.append(pixel)


## loop through the corners of pixels in quadrant 3
for corner in quad3_corners[1:]:

    ## find the x and y of all four corners of the current pixel
    bottom_left_x = corner[0]
    bottom_left_y = corner[1]
    bottom_right_x = bottom_left_x + pixel_width
    bottom_right_y = bottom_left_y
    top_right_x = bottom_right_x
    top_right_y = bottom_left_y + pixel_width
    top_left_x = bottom_left_x
    top_left_y = top_right_y

    ## put the coordinates of all four corners together into one object
    pixel = (
        (top_right_x, top_right_y), 
        (top_left_x, top_left_y),
        (bottom_left_x, bottom_left_y),
        (bottom_right_x, bottom_right_y)
    )

    ## add the pixel object to the pixels list
    pixels.append(pixel)

## loop through the corners of pixels in quadrant 4
for corner in quad4_corners[1:]:

    ## find the x and y of all four corners of the current pixel
    bottom_right_x = corner[0]
    bottom_right_y = corner[1]
    top_right_x = bottom_right_x
    top_right_y = bottom_right_y + pixel_width
    top_left_x = bottom_right_x - pixel_width
    top_left_y = bottom_right_y + pixel_width
    bottom_left_x = top_left_x
    bottom_left_y = bottom_right_y

    ## put the coordinates of all four corners together into one object
    pixel = (
        (top_right_x, top_right_y), 
        (top_left_x, top_left_y),
        (bottom_left_x, bottom_left_y),
        (bottom_right_x, bottom_right_y)
    )

    ## add the pixel object to the pixels list
    pixels.append(pixel)

## create an empty object to fill in with the loop 
## when we cut out a voxel from the macroplot lidar scan, we will need four dimensions, wich will come from the voxel's entry in this object
dimensions = {}

## loop through all of the pixels in the macroplot
for i in range(len(pixels)):

    ## grab the location of the current pixel's four walls
    x1 = pixels[i][0][0]        # right
    y1 = pixels[i][0][1]        # top
    x2 = pixels[i][2][0]        # left
    y2 = pixels[i][2][1]        # bottom

    ## assemble the four numbers into one list
    dimension = [x1, y1, x2, y2]

    ## calculate the centerpoint of the voxel
    centerpoint = [x2 + (0.5 * pixel_width), y2 + (0.5 * pixel_width)]      # the center point is: the left edge plus half of a pixel, the bottom edge plus half of a pixel

    ## add the details of the voxel to the dimensions object
    dimensions[str(i + 1)] = {"right_top_left_bottom": dimension, "centerpoint": centerpoint}

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
# with open(output_location, 'w') as output_file:
#     json.dump(dimensions, output_file)
