import statsmodels.api as sm
import scipy.optimize as so
from pylab import *

data = loadtxt("training_points_150m.txt")

k_rock = data[:, 3]
Cp_rock = data[:, 4]
rho_rock = data[:, 5]
T_surface = data[:, 6]
q_geothermal = data[:, 7]
E_borehole = data[:, 8]
T_wall_min = data[:, 9]

G_rock = q_geothermal / k_rock
C_rock = rho_rock * Cp_rock * 1e-6

#X = sm.add_constant(vstack((k_rock, C_rock, T_surface, E_borehole)).T)
X = sm.add_constant(vstack((k_rock, Cp_rock, rho_rock, T_surface, q_geothermal, E_borehole)).T)
Y = T_wall_min

model = sm.OLS(Y, X)

#print X; raise SystemExit

results = model.fit()

#print results.summary(); raise SystemExit

#def eval(k_rock, C_rock, T_surface):
def eval(k_rock, Cp_rock, rho_rock, T_surface, q_geothermal):
    #function = lambda E_borehole: abs(dot(array([1, k_rock, C_rock, T_surface, E_borehole]), results.params))
    function = lambda E_borehole: abs(dot(array([1, k_rock, Cp_rock, rho_rock, T_surface, q_geothermal, E_borehole]), results.params))
    result = so.minimize_scalar(function)
    return result.x

data = loadtxt("map_data_150m.txt")

file = open("surrogate_map_150m.txt", "w")

e = []

for i in range(data.shape[0]):
    x = data[i, 0]
    y = data[i, 1]
    k = data[i, 2]
    Cp = data[i, 3]
    rho = data[i, 4]
    C = data[i, 3] * data[i, 4] * 1e-6
    T = data[i, 5]
    q = data[i, 6]
    E1 = data[i, 7]
    #E2 = eval(k, C, T)
    E2 = eval(k, Cp, rho, T, q)
    e.append(abs(E1-E2)*100/E1)
    file.write("%.4f,%.4f,%.3f\n" % (x, y, E1-E2))

file.close()

print min(e), max(e), mean(e)
