import numpy as np

x, y, A = np.loadtxt("heat_production_data_gk25.txt").T

q0 = 15.7923
D = 10.4909

Q = q0 + D * A

np.savetxt("heat_flow_map_gk25.txt", np.vstack((x,y,A,Q)).T, fmt="%.11f")
