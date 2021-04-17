from mpl_toolkits.mplot3d import Axes3D
from osgeo import gdal
from pylab import *

def bilinear_interpolation(x, y, x1, y1, x2, y2, z1, z2, z3, z4):

    #             u
    #   x1,y2,z3--*----x2,y2,z4
    #     |       |      |
    #     |       |      |
    #     *-------O------* v
    #     |       |      |
    #     |       |      |
    #   x1,y1,z1--*----x2,y1,z2

    u = (x - x1) / (x2 - x1)
    v = (y - y1) / (y2 - y1)

    _z1 = (1.0 - u) * z1 + u * z2
    _z2 = (1.0 - u) * z3 + u * z4

    return (1.0 - v) * _z1 + v * _z2

bilinear_interpolation = vectorize(bilinear_interpolation, excluded=["x1", "y1", "x2", "y2", "z1", "z2", "z3", "z4"])

x_obs = linspace(-3, 3, 6)
y_obs = linspace(-3, 3, 6)

x_obs, y_obs = meshgrid(x_obs, y_obs)

z_obs = sin(0.5 * x_obs) * cos(y0)

x1 = linspace(-3, 3, 21)
y1 = linspace(-3, 3, 21)

x1, y1 = meshgrid(x1, y1)



fig = figure()
ax = fig.add_subplot(111, projection="3d")
ax.scatter(xi, yi, zi, "ro")

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
