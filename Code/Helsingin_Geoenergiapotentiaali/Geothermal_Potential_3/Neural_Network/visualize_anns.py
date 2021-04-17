from ann_visualizer.visualize import ann_viz
from keras.models import Sequential
from keras.layers import Dense

num_features = 5

neural_network = Sequential()

neural_network.add(Dense(4, activation="selu", kernel_initializer="normal", input_dim=num_features))
neural_network.add(Dense(4, activation="selu", kernel_initializer="normal"))
neural_network.add(Dense(1, activation="linear", kernel_initializer="normal"))

ann_viz(neural_network)
