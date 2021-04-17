import statsmodels.api as sm
import sklearn.model_selection as ms
from pylab import *

#data = loadtxt("comsol_field_300m_20m.txt")
data = loadtxt("comsol_field_150m_20m.txt")

k_rock = data[:, 1]
Cp_rock = data[:, 2]
rho_rock = data[:, 3]

T_surface = data[:, 4]
q_geothermal = data[:, 5]

E_borehole = data[:, 6]

C_rock = rho_rock * Cp_rock * 1e-6
G_rock = q_geothermal / k_rock

X = vstack((k_rock, C_rock, T_surface)).T
Y = E_borehole.reshape(-1, 1)

max_absolute_error = []
max_relative_error = []

for i in range(1000):
    X_train, X_test, Y_train, Y_test = ms.train_test_split(X, Y, test_size=0.125)
    model = sm.OLS(Y_train, sm.add_constant(X_train))
    results = model.fit()
    Y_pred = results.predict(sm.add_constant(X_test))
    absolute_error = ravel(Y_test) - Y_pred
    relative_error = abs(absolute_error) * 100.0 / ravel(Y_test)
    max_absolute_error.append(max(abs(absolute_error)))
    max_relative_error.append(max(relative_error))

print max_absolute_error
print max_relative_error

subplot(211)
hist(max_absolute_error, 21)

subplot(212)
hist(max_relative_error, 21)

show()
