from scipy.interpolate import interp1d
from pylab import *

num_bhes = 7

data1 = loadtxt("outlet_temperatures1.txt", skiprows=8)
data2 = loadtxt("outlet_temperatures2.txt", skiprows=8)
data3 = loadtxt("outlet_temperatures3.txt", skiprows=8)

num_times1 = int(data1.shape[0] / num_bhes)
num_times2 = int(data2.shape[0] / num_bhes)
num_times3 = int(data3.shape[0] / num_bhes)

print(num_times1)
print(num_times2)
print(num_times3)

t = linspace(0, 100, 10000)

for i in range(num_bhes):
    figure()
    a = (i + 0) * num_times1
    b = (i + 1) * num_times1
    r = range(a, b)
    plot(data1[r,0], data1[r,1], "y-")
    f1 = interp1d(data1[r, 0], data1[r, 1])
    a = (i + 0) * num_times2
    b = (i + 1) * num_times2
    r = range(a, b)
    plot(data2[r,0], data2[r,1], "bo")
    f2 = interp1d(data2[r, 0], data2[r, 1])
    a = (i + 0) * num_times3
    b = (i + 1) * num_times3
    r = range(a, b)
    plot(data3[r,0], data3[r,1], "r.")
    f3 = interp1d(data3[r, 0], data3[r, 1])
    #plot(t, abs(f2(t)-f3(t))*100/f2(t), "r-")

show()
