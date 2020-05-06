import meshzoo
from matplotlib import colors
from mpl_toolkits.mplot3d import Axes3D
from pylab import *

for level in [1, 2, 3, 10]:

    vertices, faces = meshzoo.icosa_sphere(level)

    x, y, z = vertices.T

    fig = figure(figsize=figaspect(3/4))
    ax = Axes3D(fig)

    ax.plot_trisurf(x, y, z, triangles=faces, edgecolor="k", color="w")

    ax.view_init(azim=45, elev=30)
    ax.set_axis_off()
    ax.grid(False)

    savefig("tessellation1_%d.png" % level)

show()
