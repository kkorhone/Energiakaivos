import scipy.interpolate
import pylab
import numpy
import arcpy
import os

class Finder:

    def __init__(self, x, y, z):
        self.x = numpy.array(x)
        self.y = numpy.array(y)
        self.z = numpy.array(z)

    def __call__(self, x, y):
        dx, dy = self.x-x, self.y-y
        dist = numpy.sqrt(dx**2 + dy**2)
        i = numpy.argsort(dist)
        if dist[i[0]] < 0.001:
            return self.x[i[0]], self.y[i[0]], self.z[i[0]], dist[i[0]]
        else:
            return x, y, numpy.nan, numpy.nan

output_path = r"E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Potential"

def read_data(path_name, field_name, verbose=False):
    print "Reading %s." % field_name
    x, y, z = [], [], []
    cursor = arcpy.da.SearchCursor(path_name, ["SHAPE@XY", field_name])
    count = 0
    for row in cursor:
        if verbose: print count, row
        _xy, _z = row
        x.append(_xy[0])
        y.append(_xy[1])
        z.append(_z)
        count += 1
        if count % 1000 == 0:
            print "Read %d points." % count
    del cursor
    print "Read %d points." % count
    return numpy.array(x), numpy.array(y), numpy.array(z)

x_map, y_map = numpy.loadtxt(r"E:\Work\Helsingin_Geoenergiapotentiaali\Map_Points\map_points.txt").T

x_surface, y_surface, T_surface = read_data(r"E:\Work\Helsingin_Geoenergiapotentiaali\Surface_Temperature\surface_temperature.shp", "T_surface")
x_geothermal, y_geothermal, q_geothermal = read_data(r"E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Heat_Flux\geothermal_heat_flux.shp", "q_geo")
x_soil, y_soil, H_soil = read_data(r"E:\Work\Helsingin_Geoenergiapotentiaali\Soil_Thickness\soil_thickness.shp", "H_soil")
x_params, y_params, k_rock = read_data(r"E:\Work\Helsingin_Geoenergiapotentiaali\Thermal_Properties\thermal_properties.shp", "lammonjoht")
x_params, y_params, Cp_rock = read_data(r"E:\Work\Helsingin_Geoenergiapotentiaali\Thermal_Properties\thermal_properties.shp", "lampokap")
x_params, y_params, rho_rock = read_data(r"E:\Work\Helsingin_Geoenergiapotentiaali\Thermal_Properties\thermal_properties.shp", "tiheys")

f_T = Finder(x_surface, y_surface, T_surface)
f_q = Finder(x_geothermal, y_geothermal, q_geothermal)
f_k = Finder(x_params, y_params, k_rock)
f_Cp = Finder(x_params, y_params, Cp_rock)
f_rho = Finder(x_params, y_params, rho_rock)
f_H = Finder(x_soil, y_soil, H_soil)

file = open(os.path.join(output_path, "map_points_samples.txt"), "w")

for i in range(len(x_map)):
    _, _, T, _ = f_T(x_map[i], y_map[i])
    _, _, q, _ = f_q(x_map[i], y_map[i])
    _, _, k, _ = f_k(x_map[i], y_map[i])
    _, _, Cp, _ = f_Cp(x_map[i], y_map[i])
    _, _, rho, _ = f_rho(x_map[i], y_map[i])
    _, _, H, _ = f_H(x_map[i], y_map[i])
    if not numpy.isnan(T) and not numpy.isnan(q) and \
       not numpy.isnan(k) and not numpy.isnan(Cp) and not numpy.isnan(rho) and \
       not numpy.isnan(H):
        file.write("%.12f %.12f %.12f %.12f %.12f %.12f %.12f %.12f\n" % (x_map[i], y_map[i], T, q, k, Cp, rho, H))
    if (i + 1) % 1000 == 0:
        print "Wrote %d points." % (i + 1)

print "Wrote %d points." % len(x_map)

file.close()
