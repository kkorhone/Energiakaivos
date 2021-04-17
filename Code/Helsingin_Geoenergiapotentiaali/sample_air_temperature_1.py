from osgeo import gdal
from pylab import *

def bilinear_interpolation(ll, lr, ul, ur, p):
    #     u
    # ul -*--- ur
    #  |  |    |
    #  *--O----* v
    #  |  |    |
    # ll -*--- lr
    u = (p[0] - ll[0]) / (lr[0] - ll[0])
    v = (p[1] - ll[1]) / (ul[1] - ll[1])
    z1 = (1.0 - u) * ll[2] + u * lr[2]
    z2 = (1.0 - u) * ul[2] + u * ur[2]
    z3 = (1.0 - v) * z1 + v * z2
    return z3

ll = (-3.0, -2.0, 120.0)
lr = (+2.0, -2.0, 140.0)
ul = (-3.0, +4.0, 150.0)
ur = (+2.0, +4.0, 170.0)

from mpl_toolkits.mplot3d import Axes3D

xi = linspace(ll[0], lr[0], 10)
yi = linspace(ll[1], ul[1], 10)

xi, yi = meshgrid(xi, yi)

zi = zeros_like(xi)

for i in range(xi.shape[0]):
    for j in range(xi.shape[1]):
        zi[i, j] = bilinear_interpolation(ll, lr, ul, ur, (xi[i,j], yi[i,j]))

fig = figure()
ax = fig.add_subplot(111, projection="3d")
ax.plot([ll[0],lr[0],ur[0],ul[0]], [ll[1],lr[1],ur[1],ul[1]], [ll[2],lr[2],ur[2],ul[2]], "ro")
ax.scatter(xi, yi, zi, "b.")

show()

raise SystemExit

x, y = loadtxt("sample_points.txt").T

raster = gdal.Open(r"Geologia\air_temperature_clipped.tif")

raster_band = raster.GetRasterBand(1)

geo_transform = raster.GetGeoTransform()

x_origin = geo_transform[0]
y_origin = geo_transform[3]

pixel_width = geo_transform[1]
pixel_height = geo_transform[5]

num_cols = raster.RasterXSize
num_rows = raster.RasterYSize

z_values = raster_band.ReadAsArray(0, 0, num_cols, num_rows)
z_values = z_values[::-1, :]
z_values[z_values==raster_band.GetNoDataValue()] = nan

x_range = linspace(x_origin+0.5*pixel_width, x_origin+num_cols*pixel_width-0.5*pixel_width, num_cols)
y_range = linspace(y_origin+0.5*pixel_height, y_origin+num_rows*pixel_height-0.5*pixel_height, num_rows)
y_range = y_range[::-1]

for i in [230]:#range(len(x)):

    col = int((x[i] - x_range[0]) / (x_range[1]-x_range[0]))
    row = int((y[i] - y_range[0]) / (y_range[1]-y_range[0]))

    plot(x_range[col], y_range[row], "bo")
    plot(x_range[col+1], y_range[row], "bo")
    plot(x_range[col], y_range[row+1], "bo")
    plot(x_range[col+1], y_range[row+1], "bo")

    text(x_range[col], y_range[row], str(z_values[row,col]))
    text(x_range[col+1], y_range[row], str(z_values[row,col+1]))
    text(x_range[col], y_range[row+1], str(z_values[row+1,col]))
    text(x_range[col+1], y_range[row+1], str(z_values[row+1,col+1]))

    plot(x[i], y[i], "ro")

    u = (x[i] - x_range[col]) / (x_range[1]-x_range[0])
    v = (y[i] - y_range[row]) / (y_range[1]-y_range[0])

    plot((1.0-u)*x_range[col]+u*x_range[col+1], y_range[row], "rx")
    plot((1.0-u)*x_range[col]+u*x_range[col+1], y_range[row+1], "rx")
    plot(x_range[col], (1.0-v)*y_range[row]+v*y_range[row+1], "rx")

    z1 = (1.0 - u) * z_values[col+0, row+0] + u * z_values[col+1, row+0]
    z2 = (1.0 - u) * z_values[col+0, row+1] + u * z_values[col+1, row+1]
    z3 = (1.0 - v) * z1 + v * z2

show()
