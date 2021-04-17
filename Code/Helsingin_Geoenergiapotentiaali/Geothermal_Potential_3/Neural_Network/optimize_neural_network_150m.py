from sklearn.preprocessing import StandardScaler
from keras.optimizers import Adadelta
from keras.models import Sequential
from keras.layers import Dense

import numpy
import pylab

# Sets up the number of features =============================================

num_features = 5
num_iterations = 5

# Loads data =================================================================

map_data = numpy.loadtxt("sampled_map_points.txt")

x_map = map_data[:, 2]
y_map = map_data[:, 3]
X_map = map_data[:, 4:]

train_data = numpy.loadtxt("train_150m_20m_min.txt")
test_data = numpy.loadtxt("test_150m_20m_min.txt")
poly_data = numpy.loadtxt("field_polies_150m_20m_min.txt")

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

num_neurons = numpy.array([0, 1, 2, 3, 4, 5])
activation_functions = numpy.array(["selu", "relu", "tanh", "sigmoid"])

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

# Iterates over each variant =================================================

csv_file = open("results.csv", "w")
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

    # Calculates statistics for variant ======================================

    for n in range(num_iterations):

        # Constructs variant =================================================

        if len(variant) == 2:
            neural_network = construct_neural_network1(variant[0], variant[1])
        elif len(variant) == 4:
            neural_network = construct_neural_network2(variant[0], variant[1], variant[2], variant[3])

        # Trains neural network ==============================================

        learning_history = neural_network.fit(X_scaled, Y_scaled, epochs=1000, verbose=0, batch_size=50)

        # Calculates prediction ==============================================

        Y_pred = response_scaler.inverse_transform(neural_network.predict(X_scaled))

        # Calculates statistics ==============================================

        absolute_error = Y_train - Y_pred

        relative_error = numpy.abs(absolute_error) * 100.0 / Y_train

        print("%d %+.6f %+.6f %+.6f %.6f %.6f" % (n, numpy.min(absolute_error), numpy.mean(absolute_error), numpy.max(absolute_error), numpy.mean(relative_error), numpy.max(relative_error)))

        # Saves results ======================================================

        min_absolute_error.append(numpy.min(absolute_error))
        max_absolute_error.append(numpy.max(absolute_error))
        max_relative_error.append(numpy.max(relative_error))

        mean_absolute_error.append(numpy.mean(absolute_error))
        mean_relative_error.append(numpy.mean(relative_error))

    counter += 1

    print(50 * "-")
    print("  %+.6f %+.6f %+.6f %.6f %.6f => %d/%d" % (numpy.mean(min_absolute_error), numpy.mean(mean_absolute_error), numpy.mean(max_absolute_error), numpy.mean(mean_relative_error), numpy.mean(max_relative_error), counter, num_variants))

    csv_file = open("results.csv", "a")
    if len(variant) == 2:
        csv_file.write("%d,%s,,,%.6f,%.6f,%.6f,%.6f,%.6f\n" % (variant[0], variant[1], numpy.mean(min_absolute_error), numpy.mean(mean_absolute_error), numpy.mean(max_absolute_error), numpy.mean(mean_relative_error), numpy.mean(max_relative_error)))
    elif len(variant) == 4:
        csv_file.write("%d,%s,%d,%s,%.6f,%.6f,%.6f,%.6f,%.6f\n" % (variant[0], variant[1], variant[2], variant[3], numpy.mean(min_absolute_error), numpy.mean(mean_absolute_error), numpy.mean(max_absolute_error), numpy.mean(mean_relative_error), numpy.mean(max_relative_error)))
    csv_file.close()
