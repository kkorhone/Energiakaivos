from scipy.interpolate import interp1d
from pylab import *

t1, Q1 = loadtxt("extraction_total_heat_rate.txt", skiprows=8).T
t1, T1 = loadtxt("extraction_volume_temperature.txt", skiprows=8).T
t2, T2 = loadtxt("recovery_volume_temperature.txt", skiprows=8).T

f1 = interp1d(t1, Q1)
f2 = interp1d(t1, T1)
f3 = interp1d(t2, T2)

t1 = logspace(-7, 2, 10001)
Q1 = f1(t1)
T1 = f2(t1)

t2 = logspace(-7, log10(10000), 100001)
T2 = f3(t2)

print(f2(0)-f3(10000))

plot(t1, T1, "r-")
plot(t2+100, T2, "b-")
axhline(T1[0], color="k", ls="--")

show()
