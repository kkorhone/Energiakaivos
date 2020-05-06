import meshzoo
from matplotlib import colors
from mpl_toolkits.mplot3d import Axes3D
from pylab import *

# bounds = [-1,0,+1]
# cmap = colors.ListedColormap(["y", "m"])
# norm = colors.BoundaryNorm(bounds, cmap.N)

def calculate_distance(v1, v2):
    dx = v1[0] - v2[0]
    dy = v1[1] - v2[1]
    dz = v1[2] - v2[2]
    return sqrt(dx**2 + dy**2 + dz**2)

vertices, faces = meshzoo.icosa_sphere(10)

min_distance = None

collars = 30 * vertices
footers = 330 * vertices

distances = []

for i in range(collars.shape[0]):
    for j in range(footers.shape[0]):
        if i == j:
            continue
        distance = calculate_distance(footers[i,:], footers[j,:])
        if distance <= 32:
            distances.append(distance)
        if min_distance:
            min_distance = min([min_distance, distance])
        else:
            min_distance = distance

print(min_distance, mean(distances))
print(distances)
print(len(distances))
hist(distances, 20)
show()
raise SystemExit

x, y, z = vertices.T

fig = figure(figsize=figaspect(3/4))
ax = Axes3D(fig)

# ax.plot_trisurf(x, y, z, triangles=faces, edgecolor="k", cmap=cmap, norm=norm)

ax.plot_trisurf(x, y, z, triangles=faces, edgecolor="k", color="y")

i = where((z <= 1e-6) & (x <= 1e-6))[0]

for j in i:
    ax.plot([0, x[j]], [0, y[j]], [0, z[j]], "y-")

h, = ax.plot(x[i], y[i], z[i], "ko", mfc="w")

ax.view_init(azim=180, elev=0)
ax.grid(False)
#ax.set_xticks([])
#ax.set_yticks([])
#ax.set_zticks([])
ax.set_axis_off()

setp(h, "zorder", 100)

show()
