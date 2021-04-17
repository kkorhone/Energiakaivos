from pylab import *

t = arange(50, 10001, 1)

data = loadtxt("T_bore_wall_1000m.txt", skiprows=8)

nt = len(t)
nz = data.shape[0] / nt

colors = ["k", "b", "g", "r"]
# targets = [-1, -0.5, -0.1]

k = 0

for i in [0, 9950]:
    a = (i + 0) * nz
    b = (i + 1) * nz
    z = data[a:b, 1]
    T = data[a:b, 0]
    j = argsort(z)
    print "i=%d t=%d mean=%.3f" % (i, t[i], mean(T[j]))
    if k > 0:
        plot(T[j], z[j], ls="--", lw=1, label=u"%.0f v l\xe4mm\xf6noton lopettamisesta"%(t[i]-50), color=colors[k])
    else:
        plot(T[j], z[j], lw=1, label=u"%.0f v l\xe4mm\xf6noton lopettamisesta"%(t[i]-50), color=colors[k])
    # if k > 0:
        # axvline(targets[k-1], color=colors[k], ls="--", lw=0.5)
    k += 1

gca().set_xticks(arange(-8, 0.5, 0.5))
gca().set_yticks(arange(-1000, 100, 100))

gca().set_xlim([-8, 0])
gca().set_ylim([-1000, 0])

xlabel(u"L\xe4mp\xf6tilapoikkeama energiakaivon sein\xe4m\xe4ll\xe4 [K]")
ylabel("Syvyys [m]")

grid(color="k", ls="--", lw=0.25)

legend()#bbox_to_anchor=(0.2, 0.2, 0.5, 0.3))

tight_layout()

savefig("wall3b.png")

show()
