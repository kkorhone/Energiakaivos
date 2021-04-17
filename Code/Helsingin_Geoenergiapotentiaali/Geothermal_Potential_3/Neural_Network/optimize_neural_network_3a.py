from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from keras.optimizers import Adadelta
from keras.models import Sequential
from keras.layers import Dense

import numpy
import time

# Sets up constants ==========================================================

num_features = 5
num_iterations = 5

# Loads training data ========================================================

# poly_id=0 k_rock=1 Cp_rock=2 rho_rock=3 T_surface=4 q_geothermal=5 E_borehole=6

data = numpy.loadtxt(r"E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Potential_3\Results_Minimum\field_300m_20m_min.txt")

X = data[:, [1, 2, 3, 4, 5]]
Y = data[:, 6].reshape(-1, 1)

# Constructs scaler ==========================================================

feature_scaler = StandardScaler()

feature_scaler.fit(X)

response_scaler = StandardScaler()

response_scaler.fit(Y)

# Builds neural network ======================================================

def build_one_layer_neural_network(num_neurons, activation_function):
    neural_network = Sequential()
    neural_network.add(Dense(num_neurons, activation=activation_function, kernel_initializer="normal", input_dim=num_features))
    neural_network.add(Dense(1, kernel_initializer="normal", activation="linear"))
    neural_network.compile(loss="mean_squared_error", optimizer=Adadelta())
    return neural_network

def build_two_layer_neural_network(num_neurons1, num_neurons2, activation_function1, activation_function2):
    neural_network = Sequential()
    neural_network.add(Dense(num_neurons1, activation=activation_function1, kernel_initializer="normal", input_dim=num_features))
    neural_network.add(Dense(num_neurons2, activation=activation_function2, kernel_initializer="normal"))
    neural_network.add(Dense(1, kernel_initializer="normal", activation="linear"))
    neural_network.compile(loss="mean_squared_error", optimizer=Adadelta())
    return neural_network

# Generates neural network variants ==========================================

num_neurons = [0, 5, 10, 15]
activation_functions = ["selu", "relu", "tanh", "sigmoid"]

bag = []

for a in range(1, len(num_neurons)):
    for b in range(len(num_neurons)):
            for A in range(len(activation_functions)):
                for B in range(len(activation_functions)):
                        if num_neurons[b] > 0:
                            layers = (num_neurons[a], num_neurons[b], activation_functions[A], activation_functions[B])
                        else:
                            layers = (num_neurons[a], activation_functions[A])
                        try:
                            bag.index(layers)
                        except:
                            bag.append(layers)

print("Optimizing %d variants." % len(bag))

# Trains each neural network variant =========================================

file = open("neural_network_variants.csv", "w")
file.write("i,num_neurons1,num_neurons2,num_neurons3,activation_function1,activation_function2,activation_function3,max_abs,max_abs_err\n")
file.close()

print("%6s %12s %12s %12s %12s" % ("i", "Elapsed time", "Total time", "Max abs err", "Max rel err"))

total_time = 0

for i in range(len(bag)):

    start_time = time.time()

    # Bluids neural network ==================================================

    layers = bag[i]

    if len(layers) == 2:
        neural_network = build_one_layer_neural_network(layers[0], layers[1])
    elif len(layers) == 4:
        neural_network = build_two_layer_neural_network(layers[0], layers[1], layers[2], layers[3])
    else:
        raise ValueError

    # Fits N times ===========================================================

    mean_absolute_error = numpy.zeros(num_iterations)
    mean_relative_error = numpy.zeros(num_iterations)

    for n in range(num_iterations):

        # Scales data ========================================================

        training_X, validation_X, training_Y, validation_Y = train_test_split(X, Y, test_size=0.333)

        training_X = feature_scaler.transform(training_X)
        training_Y = response_scaler.transform(training_Y)

        validation_X = feature_scaler.transform(validation_X)
        validation_Y = response_scaler.transform(validation_Y)

        # Fits neural network ================================================

        neural_network.fit(training_X, training_Y, batch_size=10, epochs=1000, verbose=0, validation_data=(validation_X, validation_Y))

        predicted_Y = neural_network.predict(validation_X)

        # Calculates errors ==================================================

        absolute_error = numpy.abs(response_scaler.inverse_transform(validation_Y) - response_scaler.inverse_transform(predicted_Y))
        relative_error = absolute_error * 100.0 / response_scaler.inverse_transform(validation_Y)

        mean_absolute_error[n] = numpy.mean(absolute_error)
        mean_relative_error[n] = numpy.mean(relative_error)

    elapsed_time = time.time() - start_time

    total_time += elapsed_time / 60.0

    file = open("neural_network_variants.csv", "a")
    if len(layers) == 2:
        file.write("%d,%d,,,%s,,,%.6f,%.6f\n" % (i, layers[0], layers[1], numpy.mean(mean_absolute_error), numpy.mean(mean_relative_error)))
    elif len(layers) == 4:
        file.write("%d,%d,%d,,%s,%s,,%.6f,%.6f\n" % (i, layers[0], layers[1], layers[2], layers[3], numpy.mean(mean_absolute_error), numpy.mean(mean_relative_error)))
    else:
        raise ValueError
    file.close()

    print("%6d %11.3fs %9.1fmin ===> %.6f(%.6f) ===> %.6f(%.6f)" % (i, elapsed_time, total_time, numpy.mean(mean_absolute_error), numpy.std(mean_absolute_error), numpy.mean(mean_relative_error), numpy.std(mean_relative_error)))
