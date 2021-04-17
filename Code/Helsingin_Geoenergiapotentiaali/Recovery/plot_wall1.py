from pylab import *

t = arange(50, 201, 1)

data = loadtxt("T_axis_wall_150m.txt", skiprows=8)

nt = len(t)
nz = data.shape[0] / nt

colors = ["k", "b", "g", "r"]
# targets = [-1, -0.5, -0.1]

k = 0

for i in [0, 1, 6, 46]:
    a = (i + 0) * nz
    b = (i + 1) * nz
    z = data[a:b, 1]
    T = data[a:b, 0]
    j = argsort(z)
    print "i=%d t=%d mean=%.3f" % (i, t[i], mean(T[j]))
    plot(T[j], z[j], lw=1, label=u"%.0f v l\xe4mm\xf6noton lopettamisesta"%(t[i]-50), color=colors[k])
    # if k > 0:
        # axvline(targets[k-1], color=colors[k], ls="--", lw=0.5)
    k += 1

gca().set_xticks(arange(-6, 0.5, 0.5))
gca().set_yticks(arange(-150, 10, 10))

gca().set_xlim([-6, 0])
gca().set_ylim([-150, 0])

xlabel(u"L\xe4mp\xf6tilapoikkeama energiakaivon sein\xe4m\xe4ll\xe4 [K]")
ylabel("Syvyys [m]")

grid(color="k", ls="--", lw=0.25)

legend()

tight_layout()

savefig("wall1.png")

show()
