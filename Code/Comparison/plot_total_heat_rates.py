from scipy.interpolate import interp1d
from pylab import *

data1 = loadtxt("total_heat_rate1.txt", skiprows=8)
data2 = loadtxt("total_heat_rate2.txt", skiprows=8)
data3 = loadtxt("total_heat_rate3.txt", skiprows=8)

t = linspace(0, 100, 10000)

f1 = interp1d(data1[:, 0], data1[:, 1])
f2 = interp1d(data2[:, 0], data2[:, 1])
f3 = interp1d(data3[:, 0], data3[:, 1])

plot(t, f1(t), "y-")
plot(t, f2(t), "ro")
plot(t, f3(t), "b.")

show()
