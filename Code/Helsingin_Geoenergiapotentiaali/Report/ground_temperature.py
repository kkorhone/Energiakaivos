import matplotlib

matplotlib.rcParams["font.size"] = 14

from pylab import *

q = 0.042
k = 3.0
Cp = 750
rho = 2700

Ts = 6.0
As = 7.0

alpha = k / (rho * Cp)
omega = 2.0 * pi / (365.0 * 86400.0)
delta = sqrt(2.0 * alpha / omega)

def T(z, t):
    return Ts - As * exp(-z / delta) * cos(omega * t - z / delta) + q / k * z

t = linspace(0, 2*365*86400, 2*12+1)
z = linspace(0, 35, 1001)

winter = [12, 1, 2]
spring = [3, 4, 5]
summer = [6, 7, 8]
autumn = [9, 10, 11]

figure(1, figsize=(7, 6))

for i in range(len(t)):
    month = i % 12 + 1
    if month in winter:
        print "winter", i, month
        figure(0)
        plot(i, T(0,t[i]), "co")
        figure(1)
        h1, = plot(T(z,t[i]), z, "b-", lw=2)
    elif month in spring:
        print "spring", i, month
        figure(0)
        plot(i, T(0,t[i]), "mo")
        figure(1)
        h2, = plot(T(z,t[i]), z, "m-", lw=2)
    elif month in summer:
        print "summer", i, month
        figure(0)
        plot(i, T(0,t[i]), "ro")
        figure(1)
        h3, = plot(T(z,t[i]), z, "r-", lw=2)
    elif month in autumn:
        print "autumn", i, month
        figure(0)
        plot(i, T(0,t[i]), "bo")
        figure(1)
        h4, = plot(T(z,t[i]), z, "c-", lw=2)
    else:
        raise ValueError, i, month
    figure(0)
    text(i, T(0,t[i]), str(month))

figure(0)
close()

figure(1)
h5, = plot([Ts+q/k*min(z),Ts+q/k*max(z)], [min(z),max(z)], "k--", lw=2)
#h6 = axhspan(15, 20, color=[0.85,0.85,0.85])
h6 = axhline(20, color="r", ls="--", lw=2)

setp(h5, zorder=100)

gca().set_xlim([Ts-As, Ts+As])
gca().set_xticks(arange(Ts-As, Ts+As+1))
gca().xaxis.set_ticks_position("top")
gca().xaxis.set_label_position("top")
#gca().tick_params(axis="x", top=True, labeltop=True, bottom=False, labelbottom=False)
gca().set_ylim([max(z), min(z)])

xlabel(u"L\xe4mp\xf6tila [\xb0C]")
ylabel("Syvyys [m]")

tight_layout()

legend((h1,h2,h3,h4,h5,h6), ("Talvikuukaudet", u"Kev\xe4tkuukaudet", u"Kes\xe4kuukaudet", "Syyskuukaudet", "Vuotuinen keskiarvo", "Tunkeutumissyvyys"))

tight_layout()

savefig("annual.png")

show()
