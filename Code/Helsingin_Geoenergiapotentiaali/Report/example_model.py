from pylab import *

t, T = loadtxt("example_model.txt", skiprows=8).T

N = len(t) / 3

plot(t[0*N:1*N], T[0*N:1*N], "r-", lw=1)
plot(t[1*N:2*N], T[1*N:2*N], "g-", lw=1)
plot(t[2*N:3*N], T[2*N:3*N], "b-", lw=1)

axhline(0, ls="--", color="k", lw=1)

gca().set_xlim([0, 50])
gca().set_ylim([-2, 7])

xlabel("Aika [a]")
ylabel(u"Kaivon sein\xe4m\xe4n minimil\xe4mp\xf6tila [\xb0C]")

legend(("4 MWh/a", "5 MWh/a", "6 MWh/a"))

tight_layout()

savefig("example_model.png", dpi=300)

show()
