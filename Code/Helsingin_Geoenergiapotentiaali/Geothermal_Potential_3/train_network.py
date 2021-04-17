from sklearn.preprocessing import StandardScaler
from keras.optimizers import Adadelta
from sklearn.externals import joblib 
from keras.models import Sequential
from keras.layers import Dense

import pandas
import numpy
import pylab

# Number of features =========================================================

num_features = 5

# Loads training data ========================================================

training_data = numpy.loadtxt("comsol_polies_300m.txt")

k_rock = training_data[:, 1]
Cp_rock = training_data[:, 2]
rho_rock = training_data[:, 3]
T_surface = training_data[:, 4]
q_geothermal = training_data[:, 5]
E_borehole = training_data[:, 6]

training_X = numpy.vstack((k_rock, Cp_rock, rho_rock, T_surface, q_geothermal)).T
training_Y = E_borehole.reshape(-1, 1)

# Constructs scaler ==========================================================

feature_scaler = StandardScaler()

feature_scaler.fit(training_X)

response_scaler = StandardScaler()

response_scaler.fit(training_Y)

# Scales data ================================================================

training_X = feature_scaler.transform(training_X)
training_Y = response_scaler.transform(training_Y)

# Builds neural network ======================================================

neural_network = Sequential()

neural_network.add(Dense(10, activation="relu", kernel_initializer="normal", input_dim=num_features))
neural_network.add(Dense(10, activation="relu", kernel_initializer="normal"))
neural_network.add(Dense(10, activation="relu", kernel_initializer="normal"))
neural_network.add(Dense(1, activation="linear", kernel_initializer="normal"))

neural_network.compile(loss="mean_squared_error", optimizer=Adadelta())

# Trains neural network ======================================================

learning_history = neural_network.fit(training_X, training_Y, epochs=1000, verbose=2, batch_size=5)

# Plots learning history =====================================================

pylab.figure()
pylab.plot(learning_history.history["loss"])

# Calculates prediction ======================================================

predicted_Y = neural_network.predict(training_X)

predicted_E = response_scaler.inverse_transform(predicted_Y)

# Calculates statistics ======================================================

absolute_error = E_borehole - predicted_E

relative_error = numpy.abs(absolute_error) * 100.0 / E_borehole

print("min=%.6f max=%.6f mean=%.6f" % (numpy.min(absolute_error), numpy.max(absolute_error), numpy.mean(absolute_error)))
print("mean=%.3f max=%.3f" % (numpy.mean(relative_error), numpy.max(relative_error)))

pylab.figure()
pylab.subplot(211)
pylab.hist(absolute_error)

pylab.subplot(212)
pylab.hist(relative_error)

pylab.show()
