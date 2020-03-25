from scipy.integrate import trapz, cumtrapz
from scipy.interpolate import interp1d
from scipy.optimize import minimize_scalar
from pylab import *

t, Q = loadtxt("simulation1a_total_heat_rate.txt", skiprows=8).T

#plot(t,Q, "r.-"); show(); raise SystemExit

f = interp1d(t, Q)
t = linspace(1000, 2000, 1000000)
#t = hstack((0, logspace(-6, 6, 10000000)))
print(Q[-1])
Q = f(t)
Q -= Q[-1]
print(trapz(Q*1e-9, t*365.2425*24))
plot(t,Q); show()
raise SystemExit
# dt = 10
# _t, _Q = [], []
# for year in arange(50, 1000000, dt):
    # i = where((year<=t)&(t<=(year+dt)))[0]
    # if year % max(dt,1000) == 0:
        # print("%d ka"%int(year/1000), len(i))
    # _t.append(mean(t[i]))
    # _Q.append(mean(Q[i])*1e-6)

result = minimize_scalar(lambda t: abs(f(t)-1e6), bounds=[20, 40], method="bounded")

semilogx(t, Q*1e-6, "r-")

plot([10, result.x, result.x], [1, 1, 0], "g--")
text(result.x+3, 0.02, "%.0f a"%result.x, color="g")

plot([10, 1000000], [Q[-1]*1e-6, Q[-1]*1e-6], "b--")
text(100, 1.1*Q[-1]*1e-6, "%.3f MW"%(Q[-1]*1e-6), color="b")

gca().set_xlim([10, 1000000])
gca().set_ylim([0, 1.6])

gca().set_xticks([10, 100, 1000, 10000, 100000, 1000000])
gca().set_yticks(arange(0, 1.7, 0.1))

gca().set_xticklabels(["10 a", "100 a", "1 ka", "10 ka", "100 ka", "1 Ma"])

xlabel("Time [a]")
ylabel("Heat rate [MW]")

tight_layout()

savefig("stationary.png")

show()
