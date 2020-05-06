import meshzoo
from matplotlib import colors
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.patches import FancyArrowPatch
from mpl_toolkits.mplot3d import proj3d
from pylab import *

class Arrow3D(FancyArrowPatch):
    def __init__(self, xs, ys, zs, *args, **kwargs):
        FancyArrowPatch.__init__(self, (0,0), (0,0), *args, **kwargs)
        self._verts3d = xs, ys, zs

    def draw(self, renderer):
        xs3d, ys3d, zs3d = self._verts3d
        xs, ys, zs = proj3d.proj_transform(xs3d, ys3d, zs3d, renderer.M)
        self.set_positions((xs[0],ys[0]),(xs[1],ys[1]))
        FancyArrowPatch.draw(self, renderer)

vertices, faces = meshzoo.icosa_sphere(4)

x, y, z = vertices.T

fig = figure(figsize=figaspect(2/4))
ax = Axes3D(fig)

for i in range(len(x)):
    if z[i] <= 0:
        ax.quiver3D([0],[0],[0], [x[i]], [y[i]], [z[i]], color="r", length=0.97, arrow_length_ratio=0.1)
#        ax.plot([collars[i,0],footers[i,0]], [collars[i,1],footers[i,1]], [collars[i,2],footers[i,2]], "k-", lw=1)
#        ax.plot([collars[i,0]], [collars[i,1]], [collars[i,2]], "k.")
#        ax.plot([footers[i,0]], [footers[i,1]], [footers[i,2]], "ko", mfc="r")

for i in range(len(x)):
    if z[i] <= 0:
        ax.plot([x[i]], [y[i]], [z[i]], "ro", mfc="w", mew=3, ms=10)

ax.view_init(azim=45, elev=30)

ax.set_xlabel("x", fontsize=16)
ax.set_ylabel("y", fontsize=16)
ax.set_zlabel("z", fontsize=16)

ax.set_xticklabels([])
ax.set_yticklabels([])
ax.set_zticklabels([])


savefig("bhe_axes.png")

show()
