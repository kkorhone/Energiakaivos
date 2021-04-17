from scipy.optimize import leastsq
from pylab import *

comsol_results = loadtxt("comsol_results_2.txt")
#comsol_results = loadtxt("comsol_results_1.txt")
#eed_results = loadtxt("eed_results_1.txt")

plot(comsol_results[1:,0], comsol_results[1:,1], "b.-", label="Infinite BHE field (COMSOL)")
#plot(eed_results[1:,0], eed_results[1:,2], "g.-", label="34x34 BHE field (EED)")

axhline(comsol_results[0,1], color="r", ls="-", label="Single BHE (COMSOL)")
#axhline(eed_results[0,1], color="m", ls="-", label="Single BHE (EED)")

gca().set_xlim([0, 200])
gca().set_ylim([0, 45])

gca().set_xticks(arange(0, 210, 10))
gca().set_xticklabels(arange(0, 210, 10), rotation=90)

xlabel("Borehole spacing [m]")
ylabel("Heating energy extractable from a 300-m BHE [MWh/a]")

#title("Comparison between COMSOL and EED")

legend(loc=4)

grid(ls=":")

tight_layout()

#savefig("comparison.png")

show()
