import meshzoo
from matplotlib import colors
from mpl_toolkits.mplot3d import Axes3D
from pylab import *

vertices, faces = meshzoo.icosa_sphere(4)

x, y, z = vertices.T

fig = figure(figsize=figaspect(3/4))
ax = Axes3D(fig)

i = where((z <= 1e-3) & (x <= 1e-3))[0]

ax.plot_trisurf(x, y, z, triangles=faces, edgecolor="k", color="w")
h, = ax.plot(x[i], y[i], z[i], "ko", mfc="r")

setp(h, "zorder", 100)

ax.view_init(azim=180, elev=0)
ax.set_axis_off()
ax.grid(False)

savefig("tessellation2_1.png")

fig = figure(figsize=figaspect(2/4))
ax = Axes3D(fig)

collars = 30 * vertices
footers = 330 * vertices

for i in range(len(x)):
    if z[i] <= 0:
        ax.plot([collars[i,0],footers[i,0]], [collars[i,1],footers[i,1]], [collars[i,2],footers[i,2]], "k-", lw=1)
        ax.plot([collars[i,0]], [collars[i,1]], [collars[i,2]], "k.")
        ax.plot([footers[i,0]], [footers[i,1]], [footers[i,2]], "ko", mfc="r")

ax.view_init(azim=45, elev=30)

ax.set_xlabel("x")
ax.set_ylabel("y")
ax.set_zlabel("z")

savefig("tessellation2_2.png")

show()
