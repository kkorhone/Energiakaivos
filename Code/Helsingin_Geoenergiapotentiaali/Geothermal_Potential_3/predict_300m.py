from mpl_toolkits.mplot3d import Axes3D
import statsmodels.api as sm
from pylab import *

data = loadtxt("comsol_field_300m.txt")

k_rock = data[:, 1]
Cp_rock = data[:, 2]
rho_rock = data[:, 3]
T_surface = data[:, 4]
q_geothermal = data[:, 5]
E_borehole = data[:, 6]

X = sm.add_constant(vstack((k_rock, Cp_rock*rho_rock*1e-6, T_surface)).T)
Y = E_borehole.reshape(-1, 1)

model = sm.OLS(Y, X)
results = model.fit()

print results.summary()

absolute_error = E_borehole - results.fittedvalues
relative_error = abs(absolute_error) * 100.0 / E_borehole

data = loadtxt("sampled_map_points.txt")

x = data[:, 2]
y = data[:, 3]
k_rock = data[:, 4]
Cp_rock = data[:, 5]
rho_rock = data[:, 6]
T_surface = data[:, 7]

X = sm.add_constant(vstack((k_rock, Cp_rock*rho_rock*1e-6, T_surface)).T)

E_borehole = results.predict(X)
E_hectare = 25.0 * E_borehole

savetxt("predicted_300m.txt", vstack((x, y, E_hectare)).T, fmt="%.6f %.6f %.3f")
