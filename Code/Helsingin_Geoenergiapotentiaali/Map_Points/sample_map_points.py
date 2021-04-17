import shapely.geometry
import shapefile
import pandas
import numpy

def find_closest(x_array, y_array, x_point, y_point):
    dist = numpy.sqrt((x_array-x_point)**2 + (y_array-y_point)**2)
    i = numpy.argsort(dist)
    return i[0], dist[i[0]]

class Wrapper:

    def __init__(self, shape_name):
        self.shapely_polygons = []
        self.polygon_sets = []
        self.k_rock = []
        self.Cp_rock = []
        self.rho_rock = []
        shape_reader = shapefile.Reader(shape_name)
        for shape_record in shape_reader.shapeRecords():
            self.shapely_polygons.append(shapely.geometry.shape(shape_record.shape.__geo_interface__))
            self.k_rock.append(shape_record.record[0])
            self.Cp_rock.append(shape_record.record[1])
            self.rho_rock.append(shape_record.record[2])
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

st_frame = pandas.read_excel("E:\Work\Helsingin_Geoenergiapotentiaali\Surface_Temperature\surface_temperature.xlsx")
hf_frame = pandas.read_excel("E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Heat_Flux\geothermal_heat_flux.xlsx")

x_st, y_st, st = st_frame["POINT_X"].values, st_frame["POINT_Y"].values, st_frame["T_surface"].values
x_hf, y_hf, hf = hf_frame["POINT_X"].values, hf_frame["POINT_Y"].values, hf_frame["q_geothermal"].values

wrapper = Wrapper(r"E:\Work\Helsingin_Geoenergiapotentiaali\Bedrock_Map\bedrock_map.shp")

x, y = numpy.loadtxt("map_points.txt").T

file = open("sampled_points.txt", "w")

for point_id in range(len(x)):
    poly_id = wrapper.find_index(x[point_id], y[point_id])
    j, dj = find_closest(x_st, y_st, x[point_id], y[point_id])
    k, dk = find_closest(x_hf, y_hf, x[point_id], y[point_id])
    if dj > 0 or dk > 0:
        raise ValueError, point_id
    file.write("%d %d %.6f %.6f %.2f %.0f %.0f %.3f %.3f\n" % (point_id, poly_id, x[point_id], y[point_id], wrapper.k_rock[poly_id], wrapper.Cp_rock[poly_id], wrapper.rho_rock[poly_id], st[j], hf[k]))
    if point_id % 1000 == 0 or point_id == len(x)-1:
        print "%.3f %%" % (point_id * 100 / float(len(x)-1))

file.close()
