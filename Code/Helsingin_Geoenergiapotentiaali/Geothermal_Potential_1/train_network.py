from sklearn.preprocessing import StandardScaler
from keras.optimizers import Adadelta
from sklearn.externals import joblib 
from keras.models import Sequential
from keras.layers import Dense

import pandas
import numpy
import pylab

# Number of features =========================================================

num_features = 2

# Loads training data ========================================================

training_data = numpy.loadtxt("amfiboliitti_data.txt")

B = training_data[:, 0]
E = training_data[:, 1]
T = training_data[:, 2]

i = pylab.find(T < 10)

B, E, T = B[i], E[i], T[i]

training_X = numpy.vstack((B, E)).T
training_Y = numpy.log(T).reshape(-1, 1)

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
neural_network.add(Dense(20, activation="relu", kernel_initializer="normal"))
neural_network.add(Dense(10, activation="relu", kernel_initializer="normal"))
neural_network.add(Dense(1, activation="linear", kernel_initializer="normal"))

neural_network.compile(loss="mean_squared_error", optimizer=Adadelta())

# Trains neural network ======================================================

learning_history = neural_network.fit(training_X, training_Y, epochs=5000, verbose=2, batch_size=5)

# Plots learning history =====================================================

pylab.plot(learning_history.history["loss"])
pylab.show()

# Calculates prediction ======================================================

predicted_Y = neural_network.predict(training_X)

predicted_T = response_scaler.inverse_transform(predicted_Y)

# Calculates statistics ======================================================

pylab.figure()
pylab.plot(numpy.log(T))
pylab.plot(predicted_T)

pylab.figure()
pylab.plot(T)
pylab.plot(numpy.exp(predicted_T))
pylab.show()

absolute_error = T - predicted_T

relative_error = numpy.abs(absolute_error) * 100.0 / T

print("min=%.6f max=%.6f mean=%.6f" % (numpy.min(absolute_error), numpy.max(absolute_error), numpy.mean(absolute_error)))
print("mean=%.3f max=%.3f" % (numpy.mean(relative_error), numpy.max(relative_error)))
