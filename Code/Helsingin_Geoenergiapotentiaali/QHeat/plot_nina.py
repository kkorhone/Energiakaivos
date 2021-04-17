from scipy.io import loadmat
from pylab import *

# ----------------------------------------------------------------------
# Fetches data.
# ----------------------------------------------------------------------

data = loadmat("results5.mat")

x0 = ravel(data["x0"])
y0 = ravel(data["y0"])

# ----------------------------------------------------------------------
# Plots annual energies.
# ----------------------------------------------------------------------

#figure(figsize=(11, 5))

plot(x0, y0, "k-", lw=3, label="1 kaivo")

gca().set_xlim([0, 25])
gca().set_ylim([800, 1200])

gca().set_xticks(arange(0, 30, 5))
gca().set_yticks(arange(800, 1300, 100))

xlabel("Time [a]")
ylabel("Annual energy [MWh/a]")

grid(ls="--", lw=0.25, color="k", which="both")

tight_layout()

savefig("nina.png")

savetxt("nina.txt", vstack((x0,y0)).T)

show()
