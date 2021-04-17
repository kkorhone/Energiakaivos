from pylab import *

file = open("amfiboliitti_output.txt")

state = 0

borehole_spacing = []
energy_demand = []
wall_temperature = []

for line in file:
    tokens = line.split()
    if not len(tokens) == 4:
        continue
    if tokens[0] == "Func-count":
        if state == 0:
            B = inf
        else:
            B = state * 10.0
        state += 1
    if state > 0:
        try:
            x = float(tokens[1])
            f = float(tokens[2])
            print B, x, f
            if state > 1:
                borehole_spacing.append(B)
                energy_demand.append(x)
                wall_temperature.append(f)
        except:
            pass

savetxt("amfiboliitti_data.txt", vstack((borehole_spacing, energy_demand, wall_temperature)).T, fmt="%.6f")
