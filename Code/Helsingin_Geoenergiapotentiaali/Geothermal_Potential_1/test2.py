from scipy.optimize import leastsq
from pylab import *

results1 = loadtxt("comsol_results_300_1.txt")
results2 = loadtxt("comsol_results_300_2.txt")
results3 = loadtxt("comsol_results_300_3.txt")
results4 = loadtxt("comsol_results_300_4.txt")
results5 = loadtxt("comsol_results_300_5.txt")
results6 = loadtxt("comsol_results_300_6.txt")

plot(results1[1:,0], results1[1:,1], "r.-", lw=1, label="Amfiboliitti")
plot(results2[1:,0], results2[1:,1], "g.-", lw=1, label="Gabro")
plot(results3[1:,0], results3[1:,1], "b.-", lw=1, label="Graniitti")
plot(results4[1:,0], results4[1:,1], "c.-", lw=1, label="Grano- ja kvartsidioriitti")
plot(results5[1:,0], results5[1:,1], "m.-", lw=1, label="Kiillegneissi")
plot(results6[1:,0], results6[1:,1], "y.-", lw=1, label="Kvartsi-maasalpagneissi")

axhline(results1[0,1], color="r", ls="--", lw=1)
axhline(results2[0,1], color="g", ls="--", lw=1)
axhline(results3[0,1], color="b", ls="--", lw=1)
axhline(results4[0,1], color="c", ls="--", lw=1)
axhline(results5[0,1], color="m", ls="--", lw=1)
axhline(results6[0,1], color="y", ls="--", lw=1)

axvline(160, color="k", ls="--", lw=1, label="Kynnysarvo")

gca().set_xlim([0, 200])
gca().set_ylim([0, 45])

gca().set_xticks(arange(0, 210, 10))
gca().set_xticklabels(arange(0, 210, 10), rotation=90)

xlabel("Reikavali [m]")
ylabel("300-m syvasta reiasta saatava lammitysenergia [MWh/a]")

grid(ls=":")

legend(loc="lower center")

tight_layout()

savefig("results.png")

show()
