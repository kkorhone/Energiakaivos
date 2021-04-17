from pylab import *

file = open("maapeitteen_paksuus.txt", "rt")

file.readline()

depths = []

for line in file:
    tokens = line.split(",")
    z = float(tokens[2])
    if z > -9999.000000000000000:
        depths.append(z)

file.close()

print min(depths)
print max(depths)
print mean(depths)
print median(depths)
