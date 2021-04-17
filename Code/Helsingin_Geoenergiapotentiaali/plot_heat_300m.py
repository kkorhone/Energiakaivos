from scipy.integrate import trapz
from pylab import *

t, Q = loadtxt("heat_300m.txt", skiprows=8).T

Q_renewable = Q[-1]

figure(figsize=(9, 5))

plot(t, Q, "b--")
plot(t, ones_like(t)*Q_renewable, "r--")
fill_between(t, Q, ones_like(t)*Q_renewable, color="b", alpha=0.5)
fill_between(t, 0, Q_renewable, color="r", alpha=0.5)
axvline(1000, ls="--", color="k")

gca().set_xscale("log")

gca().set_xlim([1/(86400*365.25), 1e+6])
gca().set_ylim([0, 40])

gca().set_xticks([1/(86400*365.25), 3600/(86400*365.25), 1/365.25, 1/12.0, 1.0, 10.0, 100.0, 1000.0, 1e6])
gca().set_xticklabels(["1 s", "1 t", "1 pv", "1 kk", "1 v", "10 v", "100 v", "1000 v", "1 miljoona vuotta"])

xlabel("Aika (vuotta)")
ylabel(u"L\xe4mp\xf6virta (kilowattia)")
title(u"300-metri\xe4 syv\xe4 kaivo")

#tight_layout()

print "%.0f" % (Q_renewable*1000)
print trapz((Q-Q_renewable)*1e-6, t*365.25*24.0)

savefig("heat_300m.png")

show()
