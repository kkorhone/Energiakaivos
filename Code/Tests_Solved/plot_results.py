from scipy.integrate import trapz
from pylab import *

ico = [ "ico_25_bhes_total_heat_rate.txt",
        "ico_89_bhes_total_heat_rate.txt",
        "ico_136_bhes_total_heat_rate.txt",
        "ico_337_bhes_total_heat_rate.txt" ]

uv =  [ "uv_25_bhes_total_heat_rate.txt",
        "uv_85_bhes_total_heat_rate.txt",
        "uv_145_bhes_total_heat_rate.txt",
        "uv_339_bhes_total_heat_rate.txt" ]

colors = ["r", "g", "b", "c", "m", "y", "k"]

for i in range(4):
    t1, Q1 = loadtxt(ico[i], skiprows=8).T
    t2, Q2 = loadtxt(uv[i], skiprows=8).T
    plot(t1, Q1, "-", label=ico[i], color=colors[i])
    plot(t2, Q2, "--", label=uv[i], color=colors[i])
    E1 = trapz(Q1/1000, t1*365.2425*24)
    E2 = trapz(Q2/1000, t2*365.2425*24)
    print("%.0f %.0f %.0f" % (E1, E2, abs(E1-E2)*100/E2))

xlabel("Time [a]")
ylabel("Heat rate [MW]")

gca().set_xlim([0, 100])
gca().set_ylim([0, 6])

legend()

tight_layout()

savefig("total_heat_rates.png")

show()
