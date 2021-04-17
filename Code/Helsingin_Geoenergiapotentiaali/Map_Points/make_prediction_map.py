from pylab import *

data0 = loadtxt("map_points.txt")
data1 = loadtxt("therm_cond.txt")
data2 = loadtxt("heat_cap.txt")
data3 = loadtxt("density.txt")
data4 = loadtxt("surface_temperature.txt")
data5 = loadtxt("geothermal_heat_flux.txt")

x0, y0 = data0[:, 0], data0[:, 1]

x1, y1, z1 = data1[:, 0], data1[:, 1], data1[:, 2]
x2, y2, z2 = data2[:, 0], data2[:, 1], data2[:, 2]
x3, y3, z3 = data3[:, 0], data3[:, 1], data3[:, 2]
x4, y4, z4 = data4[:, 0], data4[:, 1], data4[:, 2]
x5, y5, z5 = data5[:, 0], data5[:, 1], data5[:, 2]

dist = zeros_like(x0)

def find_index(x_arr, y_arr, x_pt, y_pt):
    dist = sqrt((x_arr-x_pt)**2+(y_arr-y_pt)**2)
    j = argsort(dist)
    return j[0], dist[j[0]]

#figure(); scatter(x1, y1, c=z1)
#figure(); scatter(x2, y2, c=z2)
#figure(); scatter(x3, y3, c=z3)
#figure(); scatter(x4, y4, c=z4)
#figure(); scatter(x5, y5, c=z5)
#show()

x, y = [], []

E_300m, E_hectare, dist = [], [], []

file = open("prediction_map_300m.txt", "w")

for i in range(len(x0)):
    j1, d1 = find_index(x1, y1, x0[i], y0[i])
    j2, d2 = find_index(x2, y2, x0[i], y0[i])
    j3, d3 = find_index(x3, y3, x0[i], y0[i])
    j4, d4 = find_index(x4, y4, x0[i], y0[i])
    j5, d5 = find_index(x5, y5, x0[i], y0[i])
    k_rock, Cp_rock, rho_rock, T_surface, q_geothermal = z1[j1], z2[j2], z3[j3], z4[j4], z5[j5]
    E_300m.append(-5.62385296 + 0.33540988 * k_rock + 4.283022 * rho_rock*Cp_rock*1e-6 + 1.10715662 * T_surface)
    E_hectare.append(25*E_300m[-1])
    dist.append([d1, d2, d3, d4, d5])
    file.write("%.4f %.4f %.2f %.0f %.0f %.3f %.3f %.3f %.3f\n" % (x0[i], y0[i], k_rock, Cp_rock, rho_rock, T_surface, q_geothermal, E_300m[-1], E_hectare[-1]))
    print "%5d %.4f %.4f %.2f %.0f %.0f %.3f %.3f %.3f %.3f" % (i, x0[i], y0[i], k_rock, Cp_rock, rho_rock, T_surface, q_geothermal, E_300m[-1], E_hectare[-1])

file.close()

E_300m, E_hectare, dist = array(dist), array(E_300m), array(E_hectare)

print amin(dist, axis=0), amax(dist, axis=0)
print amin(E_300m, axis=0), amax(E_300m, axis=0)
print amin(E_hectare, axis=0), amax(E_hectare, axis=0)

figure()
hist(E_300m, 51)
figure()
hist(E_hectare, 51)
show()
