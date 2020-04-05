from pylab import *

t1, Q1 = loadtxt("simulation1a_total_heat_rate.txt", skiprows=8).T
t2, T2 = loadtxt("simulation1a_outlet_temperature.txt", skiprows=8).T

Q2 = 1000 * 4186 * (136 * 0.6 / 1000) * (T2 - 2)

semilogx(t1, Q1*1e-6, t2, Q2*1e-6)
#semilogx(t2, T2)
grid()

show()
