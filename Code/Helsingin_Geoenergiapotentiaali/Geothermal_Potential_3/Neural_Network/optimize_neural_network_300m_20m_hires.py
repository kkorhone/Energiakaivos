from sklearn.preprocessing import StandardScaler
from keras.optimizers import Adadelta
from keras.models import Sequential
from keras.layers import Dense

import numpy
import pylab
import time

# Sets up the number of features =============================================

num_features = 5
num_iterations = 5

# Loads data =================================================================

map_data = numpy.loadtxt("sampled_map_points_gk25.txt")

x_map = map_data[:, 0]
y_map = map_data[:, 1]
X_map = map_data[:, 2:]

train_data = numpy.loadtxt("train_300m_20m_min.txt")
test_data = numpy.loadtxt("test_300m_20m_min.txt")
poly_data = numpy.loadtxt("field_polies_300m_20m_min.txt")

train_data = numpy.vstack((train_data[:,3:], test_data[:,3:], poly_data[:,1:]))

X_train = train_data[:, :5]
Y_train = train_data[:, 5].reshape(-1, 1)

# Constructs scalers =========================================================

feature_scaler = StandardScaler()

feature_scaler.fit(X_train)

response_scaler = StandardScaler()

response_scaler.fit(Y_train)

# Scales data ================================================================

X_scaled = feature_scaler.transform(X_train)
Y_scaled = response_scaler.transform(Y_train)

# Builds neural network ======================================================

def construct_neural_network1(num_neurons, activation_function):

    neural_network = Sequential()

    neural_network.add(Dense(num_neurons, activation=activation_function, kernel_initializer="normal", input_dim=num_features))
    neural_network.add(Dense(1, activation="linear", kernel_initializer="normal"))

    neural_network.compile(loss="mean_squared_error", optimizer=Adadelta(lr=1.0))

    return neural_network

def construct_neural_network2(num_neurons1, activation_function1, num_neurons2, activation_function2):

    neural_network = Sequential()

    neural_network.add(Dense(num_neurons1, activation=activation_function1, kernel_initializer="normal", input_dim=num_features))
    neural_network.add(Dense(num_neurons2, activation=activation_function2, kernel_initializer="normal"))
    neural_network.add(Dense(1, activation="linear", kernel_initializer="normal"))

    neural_network.compile(loss="mean_squared_error", optimizer=Adadelta(lr=1.0))

    return neural_network

# Generates variants =========================================================

num_neurons = numpy.array([0, 3, 4, 5, 6, 7, 8])
activation_functions = numpy.array(["selu", "relu", "tanh"])

variants = []

for num_neurons1 in num_neurons[num_neurons>0]:
    for activation_function1 in activation_functions:
        for num_neurons2 in num_neurons:
            for activation_function2 in activation_functions:
                if num_neurons2 == 0:
                    variant = (num_neurons1, activation_function1)
                else:
                    variant = (num_neurons1, activation_function1, num_neurons2, activation_function2)
                try:
                    variants.index(variant)
                except:
                    variants.append(variant)

print("Optimizing %d variants." % len(variants))

# Iterates over each variant =================================================

csv_file = open("results_hires_300m_20m.csv", "w")
csv_file.write("num_neurons1,activation_function1,num_neurons2,activation_function2,min_absolute_error,mean_absolute_error,max_absolute_error,mean_relative_error,max_relative_error\n")
csv_file.close()

counter = 0

num_variants = len(variants)

for variant in variants:

    print(50 * "=")
    print("variant=%s" % str(variant))
    print(50 * "=")

    min_absolute_error = []
    max_absolute_error = []
    max_relative_error = []

    mean_absolute_error = []
    mean_relative_error = []

    start_variant = time.time()

    # Calculates statistics for variant ======================================

    pylab.figure()

    for n in range(num_iterations):

        start_iteration = time.time()

        # Constructs variant =================================================

        if len(variant) == 2:
            neural_network = construct_neural_network1(variant[0], variant[1])
        elif len(variant) == 4:
            neural_network = construct_neural_network2(variant[0], variant[1], variant[2], variant[3])

        # Trains neural network ==============================================

        learning_history = neural_network.fit(X_scaled, Y_scaled, epochs=1000, verbose=0, batch_size=5)

        pylab.semilogy(learning_history.history["loss"])

        # Calculates prediction ==============================================

        Y_pred = response_scaler.inverse_transform(neural_network.predict(X_scaled))

        # Calculates statistics ==============================================

        time_elapsed = time.time() - start_iteration

        absolute_error = Y_train - Y_pred

        relative_error = numpy.abs(absolute_error) * 100.0 / Y_train

        print("%d %+.6f %+.6f %+.6f %.6f %.6f => %.3f s" % (n, numpy.min(absolute_error), numpy.mean(absolute_error), numpy.max(absolute_error), numpy.mean(relative_error), numpy.max(relative_error), time_elapsed))

        # Saves results ======================================================

        min_absolute_error.append(numpy.min(absolute_error))
        max_absolute_error.append(numpy.max(absolute_error))
        max_relative_error.append(numpy.max(relative_error))

        mean_absolute_error.append(numpy.mean(absolute_error))
        mean_relative_error.append(numpy.mean(relative_error))

    time_elapsed = (time.time() - start_variant) / 60.0

    counter += 1

    pylab.title("variant=%s (mean=%.3f max=%.3f)" % (variant, numpy.mean(mean_relative_error), numpy.max(max_relative_error)))
    pylab.xlabel("Epoch")
    pylab.ylabel("Loss")

    pylab.tight_layout()

    pylab.savefig("learning_history_300m_20m_%02d.png" % counter)

    pylab.close()

    print(50 * "-")
    print("  %+.6f %+.6f %+.6f %.6f %.6f => %.3f min => %d/%d" % (numpy.mean(min_absolute_error), numpy.mean(mean_absolute_error), numpy.mean(max_absolute_error), numpy.mean(mean_relative_error), numpy.mean(max_relative_error), time_elapsed, counter, num_variants))

    csv_file = open("results_hires_300m_20m.csv", "a")
    if len(variant) == 2:
        csv_file.write("%d,%s,,,%.6f,%.6f,%.6f,%.6f,%.6f\n" % (variant[0], variant[1], numpy.mean(min_absolute_error), numpy.mean(mean_absolute_error), numpy.mean(max_absolute_error), numpy.mean(mean_relative_error), numpy.mean(max_relative_error)))
    elif len(variant) == 4:
        csv_file.write("%d,%s,%d,%s,%.6f,%.6f,%.6f,%.6f,%.6f\n" % (variant[0], variant[1], variant[2], variant[3], numpy.mean(min_absolute_error), numpy.mean(mean_absolute_error), numpy.mean(max_absolute_error), numpy.mean(mean_relative_error), numpy.mean(max_relative_error)))
    csv_file.close()
