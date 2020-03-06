from mpl_toolkits.mplot3d import Axes3D
from collections import OrderedDict
import meshzoo as mz
from copy import copy
from pylab import *

def distance_between_points(p1, p2):
    dx = p1[0] - p2[0]
    dy = p1[1] - p2[1]
    dz = p1[2] - p2[2]
    return sqrt(dx**2 + dy**2 + dz**2)

def quarter_symmetry(bhe_axes):
    # Finds the first quarter axes.
    i = where((bhe_axes[:,0]>-1e-6)&(bhe_axes[:,1]>-1e-6))[0]
    axes0 = bhe_axes[i, :]
    # Mirrors the first quarter axes with respect to the y axis.
    axes1 = copy(axes0)
    axes1[:, 0] *= -1
    axes1 = vstack((axes0, axes1))
    # Mirrors the first and second quarter axes with respect to the x axis.
    axes2 = copy(axes1)
    axes2[:, 1] *= -1
    axes2 = vstack((axes1, axes2))
    # Checks for symmetry.
    bhe_counts = zeros(bhe_axes.shape[0])
    figure()
    for i in range(bhe_axes.shape[0]):
        for j in range(axes2.shape[0]):
            if distance_between_points(bhe_axes[i,:], axes2[j,:]) < 1e-6:
                bhe_counts[i] += 1
        if bhe_counts[i] == 0:
            plot(bhe_axes[i,0], bhe_axes[i,1], "ro")
        elif bhe_counts[i] == 1:
            plot(bhe_axes[i,0], bhe_axes[i,1], "yo")
        elif bhe_counts[i] == 2:
            plot(bhe_axes[i,0], bhe_axes[i,1], "go")
        elif bhe_counts[i] == 4:
            plot(bhe_axes[i,0], bhe_axes[i,1], "mo")
        else:
            raise SystemExit("Invalid BHE count.")
    plot([0, 0, 1, 1, 0], [0, 1, 1, 0, 0], "k--")
    for i in range(bhe_axes.shape[0]):
        text(bhe_axes[i,0], bhe_axes[i,1], "%.0f"%bhe_counts[i])
    if any(bhe_counts==0):
        title("Asymmetry")
    else:
        title("Symmetry with %d of %d BHEs" % (axes0.shape[0], bhe_axes.shape[0]))
    # Determines the BHE factors.
    bhe_factors = ones(axes0.shape[0])
    for i in range(axes0.shape[0]):
        for j in range(bhe_axes.shape[0]):
            if distance_between_points(axes0[i,:], bhe_axes[j,:]) < 1e-6:
                if bhe_counts[j] == 4:
                    bhe_factors[i] = 1
                elif bhe_counts[j] == 2:
                    bhe_factors[i] = 2
                elif bhe_counts[j] == 1:
                    bhe_factors[i] = 4
                else:
                    raise SystemExit("Invalid BHE count.")
    axis("equal")
    show()
    return axes0, bhe_factors

def make_bhe_axes(type, level):
    if type == "ico":
        if level == 1:
            axes, _ = mz.icosa_sphere(2) # 25
        elif level == 2:
            axes, _ = mz.icosa_sphere(4) # 89
        elif level == 3:
            axes, _ = mz.icosa_sphere(5) # 136
        elif level == 4:
            axes, _ = mz.icosa_sphere(8) # 337
    elif type == "uv":
        if level == 1:
            axes, _ = mz.uv_sphere(num_points_per_circle=6, num_circles=9) # 25 BHEs
        elif level == 2:
            axes, _ = mz.uv_sphere(num_points_per_circle=12, num_circles=15) # 85 BHEs
        elif level == 3:
            axes, _ = mz.uv_sphere(num_points_per_circle=18, num_circles=17) # 145 BHEs
        elif level == 4:
            axes, _ = mz.uv_sphere(num_points_per_circle=26, num_circles=27) # 339 BHEs
    else:
        raise ValueError("Type must be either 'ico' or 'uv'.")
    i = where(axes[:,2] <= 0)[0]
    return axes[i]

def plot_bhe_axes(bhe_axes, plot_title):
    fig = figure()
    ax = Axes3D(fig)
    ax.scatter(bhe_axes[:,0], bhe_axes[:,1], bhe_axes[:,2], "b.")
    for i in range(bhe_axes.shape[0]):
        ax.plot([0, bhe_axes[i,0]], [0, bhe_axes[i,1]], [0, bhe_axes[i,2]], "r-")
    ax.view_init(azim=0, elev=90)
    ax.set_xlabel("x")
    ax.set_ylabel("y")
    ax.set_zlabel("z")
    title("%s (%d BHEs)" % (plot_title, bhe_axes.shape[0]))

def make_bhe_field(bhe_axes, bhe_offset, bhe_length, tunnel_depth):
    tunnel_offset = array([0, 0, -tunnel_depth])
    bhe_collars = bhe_offset * bhe_axes + tunnel_offset
    bhe_footers = (bhe_offset + bhe_length) * bhe_axes + tunnel_offset
    return bhe_collars, bhe_footers

def plot_bhe_field(bhe_collars, bhe_footers, plot_title):
    fig = figure()
    ax = Axes3D(fig)
    for i in range(bhe_collars.shape[0]):
        ax.plot([bhe_collars[i,0],bhe_footers[i,0]], [bhe_collars[i,1],bhe_footers[i,1]], [bhe_collars[i,2],bhe_footers[i,2]], "r-")
        ax.plot([bhe_collars[i,0]], [bhe_collars[i,1]], [bhe_collars[i,2]], "b.")
        ax.plot([bhe_footers[i,0]], [bhe_footers[i,1]], [bhe_footers[i,2]], "r.")
    title("%s (%d BHEs)" % (plot_title, bhe_collars.shape[0]))

def write_field(txt_name, starting_points, ending_points):
    sx, sy, sz = starting_points.T
    ex, ey, ez = ending_points.T
    file = open(txt_name, "w")
    for i in range(starting_points.shape[0]):
        file.write("%.20f %.20f %.20f %.20f %.20f %.20f\n" % (sx[i], sy[i], sz[i], ex[i], ey[i], ez[i]))
    file.close()

bhe_axes = make_bhe_axes("ico", 2)

num_full_field = bhe_axes.shape[0]

bhe_axes, bhe_factors = quarter_symmetry(bhe_axes)

num_quarter_field = bhe_axes.shape[0]
sum_bhe_factors = sum(bhe_factors)

print("num_full_field=%d" % num_full_field)
print("num_quarter_field=%d" % num_quarter_field)
print("sum_bhe_factors=%d" % sum_bhe_factors)

if sum_bhe_factors != num_full_field:
    raise SystemExit("Asymmetry!")

bhe_collars, bhe_footers = make_bhe_field(bhe_axes, 50, 100, 100)

plot_bhe_axes(bhe_axes, "BHE Axes")
plot_bhe_field(bhe_collars, bhe_footers, "BHE Field")

show()
