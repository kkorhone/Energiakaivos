from sklearn.preprocessing import StandardScaler
from keras.optimizers import Adadelta
from keras.models import Sequential
from keras.layers import Dropout
from keras.layers import Dense

import numpy
import pylab

# Sets up the number of features =============================================

num_features = 5

# Loads map points ===========================================================

# map_data = numpy.loadtxt("sampled_map_points.txt")

# x_map = map_data[:, 2]
# y_map = map_data[:, 3]

# X_map = map_data[:, 4:]

map_data = numpy.loadtxt("sampled_map_points_gk25.txt")

x_map = map_data[:, 0]
y_map = map_data[:, 1]

X_map = map_data[:, 2:]

# Loads training data ========================================================

train_data = numpy.loadtxt("train_300m_20m_min.txt")
test_data = numpy.loadtxt("test_300m_20m_min.txt")
poly_data = numpy.loadtxt("field_polies_300m_20m_min.txt")

train_data = numpy.vstack((train_data[:,3:], test_data[:,3:], poly_data[:,1:]))

X_train = train_data[:, :5]
Y_train = train_data[:, 5].reshape(-1, 1)

# Displays data ==============================================================

def plot_hist(X1, X2, bins):
    w1 = numpy.ones_like(X1) / float(len(X1))
    w2 = numpy.ones_like(X2) / float(len(X2))
    pylab.hist(X1, bins, color="b", alpha=0.5, weights=w1)
    pylab.hist(X2, bins, color="r", alpha=0.5, weights=w2)
    pylab.xticks(bins, rotation=90)
    pylab.yticks(numpy.arange(0, 0.40, 0.05))

pylab.figure(figsize=(15, 3))

bins = numpy.arange(2.65, 3.35, 0.05)

pylab.subplot(151)
plot_hist(X_map[:,0], X_train[:,0], bins)
pylab.xlabel("k_rock")
pylab.ylabel("Frequency")

bins = numpy.arange(712, 734, 2)
pylab.subplot(152)
plot_hist(X_map[:,1], X_train[:,1], bins)
pylab.xlabel("Cp_rock")
pylab.gca().set_yticklabels([])

bins = numpy.arange(2640, 2940, 20)

pylab.subplot(153)
plot_hist(X_map[:,2], X_train[:,2], bins)
pylab.xlabel("rho_rock")
pylab.gca().set_yticklabels([])

bins = numpy.arange(6.6, 7.15, 0.05)

pylab.subplot(154)
plot_hist(X_map[:,3], X_train[:,3], bins)
pylab.xlabel("T_surface")
pylab.gca().set_yticklabels([])

bins = numpy.arange(40.5, 42.4, 0.1)

pylab.subplot(155)
plot_hist(X_map[:,4], X_train[:,4], bins)
pylab.xlabel("q_geothermal")
pylab.gca().set_yticklabels([])

pylab.tight_layout()

pylab.savefig("histograms_300m_20m_gk25.png")
#pylab.show()

# Constructs scalers =========================================================

feature_scaler = StandardScaler()

feature_scaler.fit(X_train)

response_scaler = StandardScaler()

response_scaler.fit(Y_train)

# Scales data ================================================================

X_scaled = feature_scaler.transform(X_train)
Y_scaled = response_scaler.transform(Y_train)

# Builds neural network ======================================================

neural_network = Sequential()

neural_network.add(Dense(4, activation="selu", kernel_initializer="normal", input_dim=num_features))
neural_network.add(Dense(4, activation="relu", kernel_initializer="normal"))
neural_network.add(Dense(1, activation="linear", kernel_initializer="normal"))

neural_network.compile(loss="mean_squared_error", optimizer=Adadelta(lr=1.0))

# Trains neural network ======================================================

learning_history = neural_network.fit(X_scaled, Y_scaled, epochs=10000, verbose=2, batch_size=5)

# Calculates prediction ======================================================

Y_pred = response_scaler.inverse_transform(neural_network.predict(X_scaled))

# Calculates statistics ======================================================

absolute_error = Y_train - Y_pred

relative_error = numpy.abs(absolute_error) * 100.0 / Y_train

# Plots neural network =======================================================

print(neural_network.summary())

# Plots learning history =====================================================

title = "Absolute error: min=%.6f max=%.6f mean=%.6f\n" % (numpy.min(absolute_error), numpy.max(absolute_error), numpy.mean(absolute_error))
title += "Relative error: mean=%.2f max=%.2f" % (numpy.mean(relative_error), numpy.max(relative_error))

pylab.figure()

pylab.semilogy(learning_history.history["loss"])
pylab.xlabel("Epoch")
pylab.ylabel("Loss")
pylab.title(title)

pylab.tight_layout()

pylab.savefig("learning_history_300m_20m_gk25.png")
#pylab.show()

# Predicts map ===============================================================

Y_map = response_scaler.inverse_transform(neural_network.predict(feature_scaler.transform(X_map)))

# Saves map ==================================================================

csv_file = open("geothermal_potential_map_300m_20m_gk25.csv", "w")

csv_file.write("x,y,k_rock,Cp_rock,rho_rock,T_surface,q_geothermal,E_borehole,E_hectare\n")

for i in range(X_map.shape[0]):
    csv_file.write("%.6f,%.6f,%.2f,%.0f,%.0f,%.3f,%.3f,%.2f,%.1f\n" % (x_map[i], y_map[i], X_map[i,0], X_map[i,1], X_map[i,2], X_map[i,3], X_map[i,4], Y_map[i], 25.0*Y_map[i]))

csv_file.close()

# Plots maps =================================================================

pylab.figure(figsize=(6, 9))

pylab.subplot(211)
pylab.scatter(x_map, y_map, s=1, c=numpy.ravel(Y_map), cmap="jet")
pylab.colorbar()
pylab.gca().set_xticklabels([])
pylab.ylabel("Y [km]")
pylab.axis("equal")
pylab.title("Energy from single borehole [MWh/a]")

pylab.subplot(212)
pylab.scatter(x_map, y_map, s=1, c=numpy.ravel(25.0*Y_map), cmap="jet")
pylab.colorbar()
pylab.xlabel("X [km]")
pylab.ylabel("Y [km]")
pylab.axis("equal")
pylab.title("Energy from one hectare [MWh/a/ha]")

pylab.tight_layout()

pylab.savefig("potential_maps_300m_20m_gk25.png")
pylab.show()
