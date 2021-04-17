from sklearn.model_selection import train_test_split
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

# 0=x 1=y 2=T_surface 3=q_geothermal 4=k_rock 5=Cp_rock 6=rho_rock 7=E_block

training_data = numpy.loadtxt("output.txt")

X = training_data[:, [2, 3, 4, 5, 6]]
Y = training_data[:, 7].reshape(-1, 1)

# Loads test data ============================================================

training_X, validation_X, training_Y, validation_Y = train_test_split(X, Y, test_size=0.333)

# Constructs scaler ==========================================================

feature_scaler = StandardScaler()

feature_scaler.fit(training_X)

response_scaler = StandardScaler()

response_scaler.fit(training_Y)

# Scales data ================================================================

training_X = feature_scaler.transform(training_X)
training_Y = response_scaler.transform(training_Y)

validation_X = feature_scaler.transform(validation_X)
validation_Y = response_scaler.transform(validation_Y)

# Builds neural network ======================================================

neural_network = Sequential()

neural_network.add(Dense(10, activation="tanh", kernel_initializer="normal", input_dim=num_features))
neural_network.add(Dense(8, activation="sigmoid", kernel_initializer="normal"))
neural_network.add(Dense(1, activation="linear", kernel_initializer="normal"))

neural_network.compile(loss="mean_squared_error", optimizer=Adadelta())

# Trains neural network ======================================================

learning_history = neural_network.fit(training_X, training_Y, epochs=1000, verbose=2, batch_size=5, validation_data=(validation_X, validation_Y))

# Plots learning history =====================================================

pylab.plot(learning_history.history["loss"])
pylab.show()

# Calculates prediction ======================================================

predicted_Y = neural_network.predict(validation_X)

# Calculates statistics ======================================================

absolute_error = validation_Y - predicted_Y

relative_error = numpy.abs(absolute_error) * 100.0 / validation_Y

print("min=%.6f max=%.6f mean=%.6f" % (numpy.min(absolute_error), numpy.max(absolute_error), numpy.mean(absolute_error)))
print("mean=%.3f max=%.3f" % (numpy.mean(relative_error), numpy.max(relative_error)))

# Saves scalers and neural network ===========================================

neural_network.save_weights("network_weights.h5")

file = open("network_topology.json", "w")

file.write(neural_network.to_json())

file.close()

joblib.dump(feature_scaler, "feature_scaler.pkl")
joblib.dump(response_scaler, "response_scaler.pkl")
