import statsmodels.api as sm

import numpy
import pylab

# Loads data =================================================================

train_data = numpy.loadtxt("train_300m_20m_min.txt")
test_data = numpy.loadtxt("test_300m_20m_min.txt")
poly_data = numpy.loadtxt("field_polies_300m_20m_min.txt")

data = numpy.vstack((train_data[:,3:], test_data[:,3:], poly_data[:,1:]))

k_rock = data[:, 0]
Cp_rock = data[:, 1]
rho_rock = data[:, 2]
T_surface = data[:, 3]
q_geothermal = data[:, 4]

E_borehole = data[:, 5]

# Displays data ==============================================================

X = numpy.vstack((k_rock, Cp_rock*rho_rock*1e-6, T_surface)).T
Y = E_borehole

model = sm.OLS(Y, sm.add_constant(X))

results = model.fit()

print results.summary()

print results.params

csv_file = open("dataset_300.csv", "w")

csv_file.write("k_rock,Cp_rock,rho_rock,T_surface,q_geothermal,E_comsol\n")

for i in range(data.shape[0]):
    csv_file.write("%.2f,%.0f,%.0f,%.3f,%.3f,%.2f\n" % (k_rock[i], Cp_rock[i], rho_rock[i], T_surface[i], q_geothermal[i], E_borehole[i]))

csv_file.close()
