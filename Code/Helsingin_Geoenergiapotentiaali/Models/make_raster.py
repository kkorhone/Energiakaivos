import arcpy
import numpy
import os

path = r"E:\Work\Helsingin_Geoenergiapotentiaali\Models"

print "Reading data...",

data = numpy.loadtxt("map.txt")

x, y, E = data[:, 0], data[:, 1], data[:, -1]

E *= 25.0

print "Done."
print "Deleting files...",

arcpy.Delete_management(os.path.join(path, "map_points.shp"))
arcpy.Delete_management(os.path.join(path, "test.tif"))

print "Done."
print "Creating shapefile...",

spatial_reference = arcpy.SpatialReference(3067)

arcpy.CreateFeatureclass_management(path, "map_points.shp", "POINT", "", "DISABLED", "DISABLED", spatial_reference)

arcpy.AddField_management(os.path.join(path, "map_points.shp"), "E", "DOUBLE", 10)#, "", "", "", "NON_NULLABLE", "REQUIRED")

print "Done."
print "Writing features..."

cursor = arcpy.da.InsertCursor(os.path.join(path, "map_points.shp"), ["SHAPE@XY", "E"])
previous = 0

for i in range(len(x)):
    cursor.insertRow([arcpy.Point(x[i], y[i]), E[i]])
    percentage = (i + 1) * 100 / len(x)
    if not percentage == previous:
        print "Written", percentage, "%"
        previous = percentage

del cursor

print "Done."
print "Writing raster...",

arcpy.PointToRaster_conversion(os.path.join(path, "map_points.shp"), "E", os.path.join(path, "test.tif"), "MEAN", "", 100)

print "Done."
