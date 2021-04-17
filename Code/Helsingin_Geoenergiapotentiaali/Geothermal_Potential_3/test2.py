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

# label = "min(abs_err)=%.3f mean(abs_err)=%.3f max(abs_err)=%.3f" % (min(absolute_error), mean(absolute_error), max(absolute_error))
# figure()
# title(label)
# hist(absolute_error, 21)

# label = "mean(rel_err)=%.1f max(rel_err)=%.1f" % (mean(relative_error), max(relative_error))
# figure()
# title(label)
# hist(relative_error, 21)

# fig = figure()
# ax = fig.add_subplot(111, projection='3d')
# ax.scatter(rho_rock*Cp_rock*1e-6, T_surface, absolute_error, ".")

# show()

data = loadtxt("bedrock_map.txt")

k_rock = data[:, 1]
Cp_rock = data[:, 2]
rho_rock = data[:, 3]
T_surface = data[:, 4]
q_geothermal = data[:, 5]
E_borehole = data[:, 6]

