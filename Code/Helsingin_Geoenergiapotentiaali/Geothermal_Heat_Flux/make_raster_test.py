import numpy
import os

path = r"E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Heat_Flux"

print "Importing arcpy..."

import arcpy

print "Done."
print "Deleting files...",

arcpy.Delete_management(os.path.join(path, "geothermal_heat_flux_test.shp"))
arcpy.Delete_management(os.path.join(path, "geothermal_heat_flux_test.tif"))

print "Done."
print "Loading data...",

data = numpy.loadtxt(os.path.join(path, "heat_production_clipped.txt"))
x, y, A = data[:, 0], data[:, 1], data[:, 2]

print "Done."
print "Creating feature class..."

spatial_reference = arcpy.SpatialReference(3067)

arcpy.CreateFeatureclass_management(path, "geothermal_heat_flux_test.shp", "POINT", "", "DISABLED", "DISABLED", spatial_reference)

arcpy.AddField_management(os.path.join(path, "geothermal_heat_flux_test.shp"), "q_geo", "DOUBLE", 10)

print "Done."
print "Writing features..."

cursor = arcpy.da.InsertCursor(os.path.join(path, "geothermal_heat_flux_test.shp"), ["SHAPE@XY", "q_geo"])
previous = 0

for i in range(len(x)):
    cursor.insertRow([arcpy.Point(x[i], y[i]), 10.4909*A[i]+15.7923])
    percentage = (i + 1) * 100 / len(x)
    if not percentage == previous:
        print "Written", percentage, "%"
        previous = percentage

del cursor

print "Done."
print "Converting to raster..."

arcpy.PointToRaster_conversion(os.path.join(path, "geothermal_heat_flux_test.shp"), "q_geo", os.path.join(path, "geothermal_heat_flux_test.tif"), "MEAN", "", 100)

print "Done."
