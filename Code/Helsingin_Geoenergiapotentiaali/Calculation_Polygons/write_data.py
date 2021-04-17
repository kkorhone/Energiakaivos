import shapefile
from pylab import *

reader = shapefile.Reader("surface_temperature_intersect.shp")
id1, rock_type1, area1, k_rock1, Cp_rock1, rho_rock1, T_surface = [], [], [], [], [], [], []
for record in reader.records():
    id1.append(record[0])
    rock_type1.append(record[1])
    area1.append(record[2])
    k_rock1.append(record[3])
    Cp_rock1.append(record[4])
    rho_rock1.append(record[5])
    T_surface.append(record[9])

reader = shapefile.Reader("geothermal_heat_flux_intersect.shp")
id2, rock_type2, area2, k_rock2, Cp_rock2, rho_rock2, q_geothermal = [], [], [], [], [], [], []
for record in reader.records():
    id2.append(record[0])
    rock_type2.append(record[1])
    area2.append(record[2])
    k_rock2.append(record[3])
    Cp_rock2.append(record[4])
    rho_rock2.append(record[5])
    q_geothermal.append(record[9])

assert id1 == id2
assert rock_type1 == rock_type2
assert area1 == area2
assert k_rock1 == k_rock2
assert Cp_rock1 == Cp_rock2
assert rho_rock1 == rho_rock2

id = array(id1)
rock_type = array(rock_type1)
area = array(area1)
k_rock = array(k_rock1)
Cp_rock = array(Cp_rock1)
rho_rock = array(rho_rock1)
T_surface = array(T_surface)
q_geothermal = array(q_geothermal)

ids = unique(id)

csv_file = open("calculation_points.csv", "w")

for id in ids:
    i = find(id1 == id)
    m1, s1 = mean(T_surface[i]), std(T_surface[i])
    m2, s2 = mean(q_geothermal[i]), std(q_geothermal[i])
    csv_file.write("%d,%d,%s,%.0f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f\n" % (id, len(i), str(unique(rock_type[i])).strip("[]'"), unique(area[i]), unique(k_rock[i]), unique(Cp_rock[i]), unique(rho_rock[i]), m1, s1, m2, s2))

csv_file.close()
