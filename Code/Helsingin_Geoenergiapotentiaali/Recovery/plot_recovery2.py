import scipy.interpolate
import scipy.optimize
import scipy.io

from pylab import *

data = scipy.io.loadmat("T_wall_ave2.mat")

t = ravel(data["t"])

T1 = ravel(data["T1"])
T2 = ravel(data["T2"])
T3 = ravel(data["T3"])

fig_size = rcParams["figure.figsize"]

figure(figsize=(1.25*fig_size[0], fig_size[1]))

plot(log10(t), T1, "r-", lw=1, label=u"150 m syv\xe4 energiakaivo")
plot(log10(t), T2, "g-", lw=1, label=u"300 m syv\xe4 energiakaivo")
plot(log10(t), T3, "b-", lw=1, label=u"1000 m syv\xe4 energiakaivo")

xlabel("Aika [v]")
ylabel(u"L\xe4mp\xf6tilapoikkeama energiakaivon sein\xe4m\xe4ll\xe4 [\xb0C]")

gca().set_xticks(log10(array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000])))
gca().set_yticks(arange(-8, 0.5, 0.5))

gca().set_xticklabels(["1", "", "", "", "", "", "", "", "", 10, "", "", "", "", "", "", "", "", 100, "", "", "", "", "", "", "", "", 1000, "", "", "", "", "", "", "", "", 10000])

gca().set_xlim([0, 4])
gca().set_ylim([-8, 0])

i = where(t >= 50)[0]

lerp1 = scipy.interpolate.interp1d(t[i], T1[i])
lerp2 = scipy.interpolate.interp1d(t[i], T2[i])
lerp3 = scipy.interpolate.interp1d(t[i], T3[i])

print "         %8s %8s %8s" % ("150m", "300m", "1000m")

print "1.0 K =>",
print "%8.3f" % scipy.optimize.fminbound(lambda x: abs(lerp1(x)+1.0), 50, 10000),
print "%8.3f" % scipy.optimize.fminbound(lambda x: abs(lerp2(x)+1.0), 50, 10000),
print "%8.3f" % scipy.optimize.fminbound(lambda x: abs(lerp3(x)+1.0), 50, 10000)

print "0.5 K =>",
print "%8.3f" % scipy.optimize.fminbound(lambda x: abs(lerp1(x)+0.5), 50, 10000),
print "%8.3f" % scipy.optimize.fminbound(lambda x: abs(lerp2(x)+0.5), 50, 10000),
print "%8.3f" % scipy.optimize.fminbound(lambda x: abs(lerp3(x)+0.5), 50, 10000)

print "0.1 K =>",
print "%8.3f" % scipy.optimize.fminbound(lambda x: abs(lerp1(x)+0.1), 50, 10000),
print "%8.3f" % scipy.optimize.fminbound(lambda x: abs(lerp2(x)+0.1), 50, 10000),
print "%8.3f" % scipy.optimize.fminbound(lambda x: abs(lerp3(x)+0.1), 50, 10000)

legend(loc=4)

grid(ls="--", color="k", lw=0.25)

tight_layout()

savefig("recovery2.png")

show()
