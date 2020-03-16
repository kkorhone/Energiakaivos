from scipy.interpolate import interp1d
from pylab import *

data1 = loadtxt("outlet_temperature1.txt", skiprows=8)
data2 = loadtxt("outlet_temperature2.txt", skiprows=8)
data3 = loadtxt("outlet_temperature3.txt", skiprows=8)

t = linspace(0, 100, 10000)

f1 = interp1d(data1[:, 0], data1[:, 1])
f2 = interp1d(data2[:, 0], data2[:, 1])
f3 = interp1d(data2[:, 0], data2[:, 1])

plot(t, f1(t), "y-")
plot(t, f2(t), "ro")
plot(t, f3(t), "b.")

show()
