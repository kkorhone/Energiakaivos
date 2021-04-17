import shapely.geometry
import shapefile
import numpy

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

x = 390334.699
y = 6672161.668

print wrapper.find_index(x, y)

x = 387443.924
y = 6681360.883

print wrapper.find_index(x, y)
