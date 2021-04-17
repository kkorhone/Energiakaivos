import shapely.geometry
import shapefile
import pandas
import numpy
import pylab

class Wrapper:

    def __init__(self, shape_name):
        self.shapely_polygons = []
        self.polygon_sets = []
        shape_reader = shapefile.Reader(shape_name)
        for shape_record in shape_reader.shapeRecords():
            self.shapely_polygons.append(shapely.geometry.shape(shape_record.shape.__geo_interface__))
            shape_points = numpy.array(shape_record.shape.points)
            polygon_set = []
            if len(shape_record.shape.parts) == 1:
                polygon_set.append(shape_points)
            else:
                parts = numpy.hstack((shape_record.shape.parts, len(shape_record.shape.points)))
                for i in range(len(parts)-1):
                    a, b = parts[i], parts[i+1]-1
                    polygon_set.append(shape_points[a:b])
            self.polygon_sets.append(polygon_set)

    def find_index(self, x, y):
        for i in range(len(self.shapely_polygons)):
            if self.shapely_polygons[i].contains(shapely.geometry.Point(x, y)):
                return i
        return -1

wrapper = Wrapper("bedrock_map.shp")

data_frame = pandas.read_excel("E:\Work\Helsingin_Geoenergiapotentiaali\Surface_Temperature\surface_temperature.xlsx")

x, y, z = data_frame["POINT_X"].values, data_frame["POINT_Y"].values, data_frame["T_surface"].values

id = numpy.zeros(len(z), dtype="int")

for i in range(len(z)):
    id[i] = wrapper.find_index(x[i], y[i])
    if i % 1000 == 0 or i == len(z)-1:
        print "%.3f %%" % (i * 100 / float(len(z)-1))

pylab.figure()

suid = numpy.sort(numpy.unique(id))

m = []

for i in suid:
    m.append(numpy.mean(z[id==i]))
    pylab.plot(x[id==i], y[id==i], ".", ms=3)

m = numpy.array(m)

numpy.savetxt("T_surface.txt", numpy.vstack((suid, m)).T, fmt="%d %.3f")

pylab.show()
