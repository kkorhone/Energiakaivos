import scipy.interpolate
import scipy.optimize
import scipy.io

from pylab import *

data = scipy.io.loadmat("T_wall_ave1.mat")

t = ravel(data["t"])

T1 = ravel(data["T1"])
T2 = ravel(data["T2"])
T3 = ravel(data["T3"])

fig_size = rcParams["figure.figsize"]

figure(figsize=(1.25*fig_size[0], fig_size[1]))

plot(t, T1, "r-", lw=1, label=u"150 m syv\xe4 energiakaivo")
plot(t, T2, "g-", lw=1, label=u"300 m syv\xe4 energiakaivo")
plot(t, T3, "b-", lw=1, label=u"1000 m syv\xe4 energiakaivo")

xlabel("Aika [v]")
ylabel(u"Keskim\xe4\xe4r\xe4inen l\xe4mp\xf6tilapoikkeama\nenergiakaivon sein\xe4m\xe4ll\xe4 [\xb0C]")

gca().set_xticks(arange(0, 210, 10))
gca().set_yticks(arange(-7, 0.5, 0.5))

gca().set_xlim([0, 200])
gca().set_ylim([-7, 0])

i = where(t >= 50)[0]

lerp1 = scipy.interpolate.interp1d(t[i], T1[i])
lerp2 = scipy.interpolate.interp1d(t[i], T2[i])
lerp3 = scipy.interpolate.interp1d(t[i], T3[i])

print "         %8s %8s %8s" % ("150m", "300m", "1000m")

print "1.0 K =>",
print "%8.3f" % scipy.optimize.fminbound(lambda x: abs(lerp1(x)+1.0), 50, 200),
print "%8.3f" % scipy.optimize.fminbound(lambda x: abs(lerp2(x)+1.0), 50, 200),
print "%8.3f" % scipy.optimize.fminbound(lambda x: abs(lerp3(x)+1.0), 50, 200)

print "0.5 K =>",
print "%8.3f" % scipy.optimize.fminbound(lambda x: abs(lerp1(x)+0.5), 50, 200),
print "%8.3f" % scipy.optimize.fminbound(lambda x: abs(lerp2(x)+0.5), 50, 200),
print "%8.3f" % scipy.optimize.fminbound(lambda x: abs(lerp3(x)+0.5), 50, 200)

print "0.1 K =>",
print "%8.3f" % scipy.optimize.fminbound(lambda x: abs(lerp1(x)+0.1), 50, 200),
print "%8.3f" % scipy.optimize.fminbound(lambda x: abs(lerp2(x)+0.1), 50, 200),
print "%8.3f" % scipy.optimize.fminbound(lambda x: abs(lerp3(x)+0.1), 50, 200)

legend(loc=4)

grid(ls="--", color="k", lw=0.25)

tight_layout()

savefig("recovery1.png")

show()
