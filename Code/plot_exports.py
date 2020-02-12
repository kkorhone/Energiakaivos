from pylab import *

thr = loadtxt("ico_total_heat_rate.txt", skiprows=8)
ihr = loadtxt("ico_individual_heat_rates.txt", skiprows=8)
ot = loadtxt("ico_outlet_temperature.txt", skiprows=8)
iot = loadtxt("ico_individual_outlet_temperatures.txt", skiprows=8)

# Plots the total heat rate.

figure()
plot(thr[:,0], thr[:,1])
xlabel("Time [a]")
ylabel("Heat rate [MW]")
title("Total heat rate")

figure()
plot(ot[:,0], ot[:,1])
xlabel("Time [a]")
ylabel(u"Fluid temperature [\xb0C]")
title("Outlet temperature")

figure()
for i in range(int(ihr.shape[0]/thr.shape[0])):
    a = (i + 0) * thr.shape[0]
    b = (i + 1) * thr.shape[0]
    r = range(a, b)
    print(i,r)
    plot(ihr[r, 0], 1000*ihr[r, 1], label="BHE%d"%(i+1))
xlabel("Time [a]")
ylabel("Heat rate [kW]")
title("Individual heat rates")

figure()
for i in range(int(iot.shape[0]/ot.shape[0])):
    a = (i + 0) * thr.shape[0]
    b = (i + 1) * thr.shape[0]
    r = range(a, b)
    print(i,r)
    plot(iot[r, 0], iot[r, 1], label="BHE%d"%(i+1))
xlabel("Time [a]")
ylabel(u"Fluid temperature [\xb0C]")
title("Individual outlet temperatures")

#show()
