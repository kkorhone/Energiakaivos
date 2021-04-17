from sklearn.preprocessing import StandardScaler
from keras.models import model_from_json
from sklearn.externals import joblib 

import numpy

file = open("network_topology.json", "r")

neural_network = model_from_json(file.read())

file.close()

neural_network.load_weights("network_weights.h5")

print(neural_network.summary())

response_scaler = joblib.load("response_scaler.pkl")
feature_scaler = joblib.load("feature_scaler.pkl")

data = numpy.loadtxt("map_data.txt")

map_x = data[:, 0].reshape(-1, 1)
map_y = data[:, 1].reshape(-1, 1)

# map_data: 0=x 1=y 2=T_surface 3=q_geothermal 4=k_rock 5=Cp_rock 6=rho_rock 7=H_soil
# features: 2=T_surface 3=q_geothermal 4=k_rock 5=Cp_rock 6=rho_rock

map_X = data[:, 2:-1]

predict_X = feature_scaler.transform(map_X)
predict_Y = neural_network.predict(predict_X)

map_Y = response_scaler.inverse_transform(predict_Y)

print(map_x.shape)
print(map_y.shape)

print(map_X.shape)
print(map_Y.shape)

numpy.savetxt("map.txt", numpy.hstack((map_x, map_y, map_X, map_Y)), fmt="%.12f")
