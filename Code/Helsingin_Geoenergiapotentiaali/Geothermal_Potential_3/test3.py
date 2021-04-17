from pylab import *

data = loadtxt("map_point_samples.txt")

k_rock = data[:, 4]
Cp_rock = data[:, 5]
rho_rock = data[:, 6]

T_surface = data[:, 7]
q_geothermal = data[:, 8]

C_rock = rho_rock * Cp_rock * 1e-6

print unique(k_rock)
print unique(C_rock)

subplot(221)
hist(k_rock, 100)
subplot(222)
hist(C_rock, 100)

subplot(223)
hist(T_surface, 100)
subplot(224)
hist(q_geothermal, 100)

show()
