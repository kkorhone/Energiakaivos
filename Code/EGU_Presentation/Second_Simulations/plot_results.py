from scipy.interpolate import interp1d
from scipy.integrate import trapz
from pylab import *

blurp = "2MW"

def plot_plot(bhe_length, *args, **kwargs):

    print(70*"-")
    print("bhe_length", bhe_length)

    data = loadtxt("ico_field_136_%dm_%s_results.txt" % (bhe_length, blurp))

    dQ = data[-1,1] - data[-1,2] - data[-1,3]

    Q_total = interp1d(data[:,0], data[:,1])
    Q_outside = interp1d(data[:,0], data[:,2]+data[:,3])
    T_field = interp1d(data[:,0], data[:,4])
    T_outlet = interp1d(data[:,0], data[:,5])

    t = 10**linspace(-1, 4, 1000)

    semilogx(t, Q_total(t)/1000, *args, **kwargs)

plot_plot(300, "c-")
plot_plot(400, "b-")
plot_plot(500, "g-")
plot_plot(600, "r-")

if blurp == "1MW":
    text(44.22440, 1050, "44 a", rotation=45)
    text(132.47, 1050, "132 a", rotation=45)
    text(360.21, 1050, "360 a", rotation=45)
    text(709.33, 1050, "709 a", rotation=45)
elif blurp == "2MW":
    text(2.8, 2075, "3 a", rotation=45)
    text(12.65, 2075, "13 a", rotation=45)
    text(45.778, 2075, "46 a", rotation=45)
    text(109.4, 2075, "109 a", rotation=45)
else:
    raise ValueError

xlabel("Time [a]")
ylabel("Heat rate [kW]")

gca().set_xlim([1e-1, 1e+4])

if blurp == "1MW":
    gca().set_ylim([0, 1200])
    gca().set_yticks(arange(0, 1400, 200))
elif blurp == "2MW":
    gca().set_ylim([0, 2400])
    gca().set_yticks(arange(0, 2600, 200))
else:
    raise ValueError

#legend(("300-m BHEs", "400-m BHEs", "500-m BHEs", "600-m BHEs"), loc=3)

grid(ls="--", color="k", lw=0.25, which="both")

tight_layout()

savefig("fig_%s.png" % blurp)

show()

#       300m     400m   500m    600m
# 1MW  44.22   132.47 360.21  709.33
# 2MW   2.8018  12.65  45.778 109.4
