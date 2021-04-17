from pylab import *
import gtkpy.tm as tm

x_gk25, y_gk25 = loadtxt("map_points_gk25.txt").T
x_tm35, y_tm35 = loadtxt("map_points.txt").T

gk25_projection = tm.TransverseMercatorProjection(tm.GRS80_ELLIPSOID, 25.0, 25.5e6, 1.0)

latitude, longitude = gk25_projection.inverse_project(x_gk25, y_gk25)

x_tm35_from_gk25, y_tm35_from_gk25 = tm.TM35_PROJECTION.project(latitude, longitude)

csv_file = open("map_points_gk25_tm35.csv", "w")

csv_file.write("x_gk25,y_gk25,x_tm35_from_gk25,y_tm35_from_gk25,dist,x_tm35,y_tm35\n")

for _x_gk25, _y_gk25, _x_tm35_from_gk25, _y_tm35_from_gk25 in zip(x_gk25, y_gk25, x_tm35_from_gk25, y_tm35_from_gk25):
    dx, dy = x_tm35-_x_tm35_from_gk25, y_tm35-_y_tm35_from_gk25
    dist = sqrt(dx**2 + dy**2)
    i = argsort(dist)[0]
    csv_file.write("%.11f,%.11f,%.11f,%.11f,%.11f,%.11f,%.11f\n" % (_x_gk25, _y_gk25, _x_tm35_from_gk25, _y_tm35_from_gk25, dist[i], x_tm35[i], y_tm35[i]))

csv_file.close()
