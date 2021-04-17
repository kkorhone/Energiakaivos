from pylab import *

annual = loadtxt("annual.txt")
cumulative = loadtxt("cumulative.txt")

figure(figsize=(8, 5))

plot(annual[:,0], annual[:,1], "r-", lw=2, label="vuotuinen")
plot(cumulative[:,0], cumulative[:,1], "b-", lw=2, label="kumulatiivinen")

xlabel("Aika [v]")
ylabel(u"Varoet\xe4isyys [m]")

gca().set_xticks(arange(0, 105, 5))
gca().set_yticks(arange(0, 80, 5))

gca().set_xlim([10, 100])
gca().set_ylim([10, 75])

grid()

legend(loc=4)

tight_layout()

savefig("varoetaisyys.png")

show()
