from mpl_toolkits.mplot3d import Axes3D
from scipy.interpolate import interp2d
from osgeo import gdal
from pylab import *

x_obs = linspace(-3, 3, 6)
y_obs = linspace(-3, 3, 6)

x_obs, y_obs = meshgrid(x_obs, y_obs)
z_obs = sin(0.5 * x_obs) * cos(y_obs)
x_obs, y_obz, z_obs = ravel(x_obs), ravel(y_obs), ravel(z_obs)

lerp = interp2d(x_obs, y_obs, z_obs)

x_calc = linspace(-3, 3, 21)
y_calc = linspace(-3, 3, 21)
z_calc = lerp(x_calc, y_calc)

print x_obs.shape, y_obs.shape, z_obs.shape

#x_obs, y_obs, z_obs = reshape(x_obs, (6, 6)), reshape(y_obs, (6, 6)), reshape(z_obs, (6, 6))

fig = figure()
ax = fig.add_subplot(111, projection="3d")
ax.plot(x_obs, y_obs, z_obs, "ro")
ax.plot(x_calc, y_calc, z_calc, "b.")

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
