import gtkpy.tm as tm
import numpy
import os

path = r"E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Heat_Flux"

print "Importing arcpy..."

import arcpy

print "Done."
print "Deleting files...",

arcpy.Delete_management(os.path.join(path, "geothermal_heat_flux_gk25.shp"))
arcpy.Delete_management(os.path.join(path, "geothermal_heat_flux_gk25.tif"))

print "Done."
print "Loading data...",

#data = numpy.loadtxt(os.path.join(path, "heat_production_clipped.txt"))
#x, y, A = data[:, 0], data[:, 1], data[:, 2]

data = numpy.loadtxt(os.path.join(path, "heat_flow_density.txt"))
x, y, q = data[:, 0], data[:, 1], data[:, 2]

latitude, longitude = tm.TM35_PROJECTION.inverse_project(x, y)

gk25_projection = tm.TransverseMercatorProjection(tm.GRS80_ELLIPSOID, 25.0, 25.5e6, 1.0)

x, y = gk25_projection.project(latitude, longitude)

print "Done."
print "Creating feature class..."

spatial_reference = arcpy.SpatialReference(3879)

arcpy.CreateFeatureclass_management(path, "geothermal_heat_flux_gk25.shp", "POINT", "", "DISABLED", "DISABLED", spatial_reference)

arcpy.AddField_management(os.path.join(path, "geothermal_heat_flux_gk25.shp"), "q_geo", "DOUBLE", 10)

print "Done."
print "Writing features..."

cursor = arcpy.da.InsertCursor(os.path.join(path, "geothermal_heat_flux_gk25.shp"), ["SHAPE@XY", "q_geo"])
previous = 0

for i in range(len(x)):
    #cursor.insertRow([arcpy.Point(x[i], y[i]), 10.4909*A[i]+15.7923])
    cursor.insertRow([arcpy.Point(x[i], y[i]), q[i]])
    percentage = (i + 1) * 100 / len(x)
    if not percentage == previous:
        print "Written", percentage, "%"
        previous = percentage

del cursor

print "Done."
print "Converting to raster..."

arcpy.PointToRaster_conversion(os.path.join(path, "geothermal_heat_flux_gk25.shp"), "q_geo", os.path.join(path, "geothermal_heat_flux_gk25.tif"), "MEAN", "", 100)

print "Done."
