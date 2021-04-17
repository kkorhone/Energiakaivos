import pandas
import numpy

# Relevant columns: POINT_X, POINT_Y

point_frame = pandas.read_excel("map_points_gk25.xlsx")

x_point, y_point = point_frame["POINT_X"].values, point_frame["POINT_Y"].values

# Relevant columns: POINT_X, POINT_Y, Therm_Cond, Spec_Heat, Density

rock_frame = pandas.read_excel("bedrock_map_intersect_gk25.xlsx")

x_rock, y_rock, k_rock, Cp_rock, rho_rock = rock_frame["POINT_X"].values, rock_frame["POINT_Y"].values, rock_frame["Therm_Cond"].values, rock_frame["Spec_Heat"].values, rock_frame["Density"].values

# Relevant columns: POINT_X, POINT_Y, GRID_CODE

surface_frame = pandas.read_excel("surface_temperature_gk25.xlsx")

x_surface, y_surface, T_surface = surface_frame["POINT_X"].values, surface_frame["POINT_Y"].values, surface_frame["GRID_CODE"].values

# Relevant columns: POINT_X, POINT_Y, GRID_CODE

geothermal_frame = pandas.read_excel("geothermal_heat_flux_gk25.xlsx")

x_geothermal, y_geothermal, q_geothermal = geothermal_frame["POINT_X"].values, geothermal_frame["POINT_Y"].values, geothermal_frame["GRID_CODE"].values

# Joins data frames.

joined_data = []

for x, y in zip(x_point, y_point):
    row = [x, y]
    # Thermogeological parameters.
    dx, dy = x-x_rock, y-y_rock
    dist = numpy.sqrt(dx**2 + dy**2)
    i = numpy.argsort(dist)[0]
    assert dist[i] == 0
    #row.append(i)
    #row.append(dist[i])
    #row.append(x_rock[i])
    #row.append(y_rock[i])
    row.append(k_rock[i])
    row.append(Cp_rock[i])
    row.append(rho_rock[i])
    # Surface temperature.
    dx, dy = x-x_surface, y-y_surface
    dist = numpy.sqrt(dx**2 + dy**2)
    i = numpy.argsort(dist)[0]
    assert dist[i] == 0
    #row.append(i)
    #row.append(dist[i])
    #row.append(x_surface[i])
    #row.append(y_surface[i])
    row.append(T_surface[i])
    # Geothermal heat flux.
    dx, dy = x-x_geothermal, y-y_geothermal
    dist = numpy.sqrt(dx**2 + dy**2)
    i = numpy.argsort(dist)[0]
    assert dist[i] == 0
    #row.append(i)
    #row.append(dist[i])
    #row.append(x_geothermal[i])
    #row.append(y_geothermal[i])
    row.append(q_geothermal[i])
    joined_data.append(row)

print len(joined_data)

csv_file = open("sampled_map_points_gk25.csv", "w")
txt_file = open("sampled_map_points_gk25.txt", "w")

csv_file.write("x,y,k_rock,Cp_rock,rho_rock,T_surface,q_geothermal\n")

for row in joined_data:
    csv_file.write("%f,%f,%f,%f,%f,%f,%f\n" % tuple(row))
    txt_file.write("%f %f %f %f %f %f %f\n" % tuple(row))

csv_file.close()
txt_file.close()
