from keras.wrappers.scikit_learn import KerasRegressor
from sklearn.model_selection import train_test_split
from sklearn.model_selection import cross_val_score
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import KFold
from sklearn.pipeline import Pipeline
from keras.optimizers import Adadelta
from keras.models import Sequential
from keras.layers import Dense
import numpy
import pylab
import time

# Load =======================================================================

data = numpy.loadtxt(r"E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Potential_3\Results_Minimum\field_300m_20m_min.txt")

X, Y = data[:, 1:-1], data[:, -1].reshape(-1, 1)

feature_scaler = StandardScaler()
response_scaler = StandardScaler()

feature_scaler.fit(X)
response_scaler.fit(Y)

X = feature_scaler.transform(X)
Y = response_scaler.transform(Y)

X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size=0.333)

print("num_data=%d num_train=%d num_test=%d" % (data.shape[0], len(Y_train), len(Y_test)))

num_features = X_train.shape[1]

# Model ======================================================================

def create_neural_network_1(num_neurons, activation_function):
    model = Sequential()
    model.add(Dense(num_neurons, activation=activation_function, kernel_initializer="normal", input_dim=num_features))
    model.add(Dense(1, kernel_initializer="normal", activation="linear"))
    model.compile(loss="mean_squared_error", optimizer=Adadelta())
    return model

def create_neural_network_2(num_neurons1, num_neurons2, activation_function1, activation_function2):
    model = Sequential()
    model.add(Dense(num_neurons1, activation=activation_function1, kernel_initializer="normal", input_dim=num_features))
    model.add(Dense(num_neurons2, activation=activation_function2, kernel_initializer="normal"))
    model.add(Dense(1, kernel_initializer="normal", activation="linear"))
    model.compile(loss="mean_squared_error", optimizer=Adadelta())
    return model

def create_neural_network_3(num_neurons1, num_neurons2, num_neurons3, activation_function1, activation_function2, activation_function3):
    model = Sequential()
    model.add(Dense(num_neurons1, activation=activation_function1, kernel_initializer="normal", input_dim=num_features))
    model.add(Dense(num_neurons2, activation=activation_function2, kernel_initializer="normal"))
    model.add(Dense(num_neurons3, activation=activation_function3, kernel_initializer="normal"))
    model.add(Dense(1, kernel_initializer="normal", activation="linear"))
    model.compile(loss="mean_squared_error", optimizer=Adadelta())
    return model

# Fit ========================================================================

num_neurons = [0, 5, 10, 15, 20, 25, 30]
activation_functions = ["selu", "relu", "tanh", "sigmoid"]

bag = []

for a in range(1, len(num_neurons)):
    for b in range(len(num_neurons)):
        for c in range(len(num_neurons)):
            for A in range(len(activation_functions)):
                for B in range(len(activation_functions)):
                    for C in range(len(activation_functions)):
                        if num_neurons[b] == 0 and num_neurons[c] == 0:
                            layers = (num_neurons[a], activation_functions[A])
                        elif num_neurons[b] == 0:
                            layers = (num_neurons[a], num_neurons[c], activation_functions[A], activation_functions[C])
                        elif num_neurons[c] == 0:
                            layers = (num_neurons[a], num_neurons[b], activation_functions[A], activation_functions[B])
                        else:
                            layers = (num_neurons[a], num_neurons[b], num_neurons[c], activation_functions[A], activation_functions[B], activation_functions[C])
                        try:
                            bag.index(layers)
                        except:
                            bag.append(layers)

print("Optimizing %d variants." % len(bag))

file = open("topology_optimization.csv", "w")
file.write("i,num_neurons1,num_neurons2,num_neurons3,activation_function1,activation_function2,activation_function3,mean,std\n")
file.close()

print("%5s %15s %20s %10s" % ("i", "Elapsed time", "Total time", "Mean"))

total_time = 0

for i in range(len(bag)):

    start_time = time.time()

    if len(bag[i]) == 2:
        def create_ann(): return create_neural_network_1(bag[i][0], bag[i][1])
    elif len(bag[i]) == 4:
        def create_ann(): return create_neural_network_2(bag[i][0], bag[i][1], bag[i][2], bag[i][3])
    elif len(bag[i]) == 6:
        def create_ann(): return create_neural_network_3(bag[i][0], bag[i][1], bag[i][2], bag[i][3], bag[i][4], bag[i][5])
    else:
        raise ValueError

    model = create_ann()

    model.fit(X_train, Y_train, batch_size=5, epochs=2000, verbose=0, validation_data=(X_test, Y_test))

    Y_pred = model.predict(X_test)

    absolute_error = numpy.ravel(Y_test) - numpy.ravel(Y_pred)
    relative_error = abs(absolute_error) * 100.0 / numpy.ravel(Y_test)

    file = open("topology_optimization.csv", "a")
    if len(bag[i]) == 2:
        file.write("%d,%d,,%s,,%.6f\n" % (i, bag[i][0], bag[i][1], max(relative_error)))
    elif len(bag[i]) == 4:
        file.write("%d,%d,%d,%s,%s,%.6f\n" % (i, bag[i][0], bag[i][1], bag[i][2], bag[i][3], max(relative_error)))
    elif len(bag[i]) == 6:
        file.write("%d,%d,%d,%d,%s,%s,%s,%.6f\n" % (i, bag[i][0], bag[i][1], bag[i][2], bag[i][3], bag[i][4], bag[i][5], max(relative_error)))
    else:
        raise ValueError
    file.close()

    elapsed_time = time.time() - start_time

    total_time += elapsed_time / 60.0

    print("%5d %14.3fs %17.1fmin %+10.1f" % (i, elapsed_time, total_time, max(relative_error)))
