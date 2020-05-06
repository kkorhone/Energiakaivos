from matplotlib.tri import Triangulation
from mayavi import mlab
from pylab import *

data = loadtxt("data25.txt", skiprows=9)



raise SystemExit


triangulation = Triangulation(data[:,0], data[:,1])

cmap = get_cmap("rainbow")

fig = figure(figsize=(9, 6))

print(min(data[:,2]), max(data[:,2]))

tripcolor(triangulation, data[:,2], cmap=cmap, vmin=-20, vmax=0)
colorbar(label="Temperature disturbance [K]")
xlabel("X [m]")
ylabel("Z [m]")
title("Temperature disturbance after %.0f years" % 27)
gca().set_xlim([-500, 500])
gca().set_ylim([-1900, -1300])
#axis("equal")

tight_layout()

show()
