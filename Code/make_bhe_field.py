from mpl_toolkits.mplot3d import Axes3D
from collections import OrderedDict
import meshzoo as mz
from copy import copy
from pylab import *

def distance_between_points(p1, p2):
    return sqrt((p1[0]-p2[0])**2+(p1[1]-p2[1])**2+(p1[2]-p2[2])**2)

def _quarter_symmetry(bhe_axes):
    # Finds the BHEs located in the first quadrant.
    i = where((bhe_axes[:,0]>-1e-6)&(bhe_axes[:,1]>-1e-6))[0]
    quad_axes = bhe_axes[i, :]
    # Mirrors the first quadrant axes with respect to the y axis.
    half_axes = copy(quad_axes)
    half_axes[:, 0] *= -1
    half_axes = vstack((quad_axes, half_axes))
    # Mirrors the first and second quadrant axes with respect to the x axis.
    full_axes = copy(half_axes)
    full_axes[:, 1] *= -1
    full_axes = vstack((half_axes, full_axes))
    # Calculates the number of times the BHEs are found in the fully reflected dataset and plots the results.
    bhe_counts = zeros(bhe_axes.shape[0])
    figure()
    for i in range(bhe_axes.shape[0]):
        for j in range(full_axes.shape[0]):
            if distance_between_points(bhe_axes[i,:], full_axes[j,:]) < 1e-6:
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
    # Plots the first quadrant.
    plot([0, 0, 1, 1, 0], [0, 1, 1, 0, 0], "k--")
    for i in range(bhe_axes.shape[0]):
        text(bhe_axes[i,0], bhe_axes[i,1], "%.0f"%bhe_counts[i])
    # Checks for symmetry.
    if any(bhe_counts==0):
        title("Asymmetry")
    else:
        title("Symmetry with %d of %d BHEs" % (quad_axes.shape[0], bhe_axes.shape[0]))
    # Determines the BHE factors and the cut planes.
    bhe_factors = ones(quad_axes.shape[0])
    cut_planes = zeros(quad_axes.shape[0])
    for i in range(quad_axes.shape[0]):
        if abs(quad_axes[i,0]) < 1e-6 and abs(quad_axes[i,1]) < 1e-6:
            cut_planes[i] = 101
        elif abs(quad_axes[i,1]) < 1e-6:
            cut_planes[i] = 102
        elif abs(quad_axes[i,0]) < 1e-6:
            cut_planes[i] = 103
        else:
            cut_planes[i] = 104
        for j in range(bhe_axes.shape[0]):
            if distance_between_points(quad_axes[i,:], bhe_axes[j,:]) < 1e-6:
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
    return quad_axes, bhe_factors, cut_planes

def quarter_symmetry(bhe_collars, bhe_footers):
    # Finds the BHEs located in the first quadrant.
    i = where((bhe_collars[:,0]>-1e-6)&(bhe_collars[:,1]>-1e-6))[0]
    quad_collars = bhe_collars[i, :]
    quad_footers = bhe_footers[i, :]
    # Mirrors the first quadrant axes with respect to the y axis.
    half_collars = []
    half_footers = []
    n = array([0.0, 1.0, 0.0]);
    for i in range(quad_collars.shape[0]):
        half_collars.append(quad_collars[i,:]-2.0*dot(quad_collars[i,:],n)*n);
        half_footers.append(quad_footers[i,:]-2.0*dot(quad_footers[i,:],n)*n);
    half_collars = array(half_collars)
    half_footers = array(half_footers)
    half_collars = vstack((quad_collars, half_collars))
    half_footers = vstack((quad_footers, half_footers))
    # Mirrors the first and second quadrant axes with respect to the x axis.
    full_collars = []
    full_footers = []
    n = array([1.0, 0.0, 0.0]);
    for i in range(half_collars.shape[0]):
        full_collars.append(half_collars[i,:]-2.0*dot(half_collars[i,:],n)*n);
        full_footers.append(half_footers[i,:]-2.0*dot(half_footers[i,:],n)*n);
    full_collars = array(full_collars)
    full_footers = array(full_footers)
    full_collars = vstack((half_collars, full_collars))
    full_footers = vstack((half_footers, full_footers))
    # Calculates the number of times the BHEs are found in the fully reflected dataset and plots the results.
    bhe_counts = zeros(bhe_collars.shape[0])
    fig = figure()
    ax = Axes3D(fig)
    for i in range(bhe_collars.shape[0]):
        for j in range(full_collars.shape[0]):
            if distance_between_points(bhe_collars[i,:], full_collars[j,:]) < 1e-6 and distance_between_points(bhe_footers[i,:], full_footers[j,:]) < 1e-6:
                bhe_counts[i] += 1
        if bhe_counts[i] == 0:
            ax.plot([bhe_collars[i,0]], [bhe_collars[i,1]], [bhe_collars[i,2]], "r.")
            ax.plot([bhe_footers[i,0]], [bhe_footers[i,1]], [bhe_footers[i,2]], "ro")
            ax.plot([bhe_collars[i,0],bhe_footers[i,0]], [bhe_collars[i,1],bhe_footers[i,1]], [bhe_collars[i,2],bhe_footers[i,2]], "r-")
        elif bhe_counts[i] == 1:
            ax.plot([bhe_collars[i,0]], [bhe_collars[i,1]], [bhe_collars[i,2]], "y.")
            ax.plot([bhe_footers[i,0]], [bhe_footers[i,1]], [bhe_footers[i,2]], "yo")
            ax.plot([bhe_collars[i,0],bhe_footers[i,0]], [bhe_collars[i,1],bhe_footers[i,1]], [bhe_collars[i,2],bhe_footers[i,2]], "y-")
        elif bhe_counts[i] == 2:
            ax.plot([bhe_collars[i,0]], [bhe_collars[i,1]], [bhe_collars[i,2]], "g.")
            ax.plot([bhe_footers[i,0]], [bhe_footers[i,1]], [bhe_footers[i,2]], "go")
            ax.plot([bhe_collars[i,0],bhe_footers[i,0]], [bhe_collars[i,1],bhe_footers[i,1]], [bhe_collars[i,2],bhe_footers[i,2]], "g-")
        elif bhe_counts[i] == 4:
            ax.plot([bhe_collars[i,0]], [bhe_collars[i,1]], [bhe_collars[i,2]], "m.")
            ax.plot([bhe_footers[i,0]], [bhe_footers[i,1]], [bhe_footers[i,2]], "mo")
            ax.plot([bhe_collars[i,0],bhe_footers[i,0]], [bhe_collars[i,1],bhe_footers[i,1]], [bhe_collars[i,2],bhe_footers[i,2]], "m-")
        else:
            raise SystemExit("Invalid BHE count.")
    # Checks for symmetry.
    if any(bhe_counts==0):
        title("Asymmetry")
    else:
        title("Symmetry with %d of %d BHEs" % (quad_collars.shape[0], bhe_collars.shape[0]))
    # Determines the BHE factors and the cut planes.
    bhe_factors = ones(quad_collars.shape[0])
    cut_planes = zeros(quad_collars.shape[0])
    for i in range(quad_collars.shape[0]):
        if abs(quad_collars[i,0]) < 1e-6 and abs(quad_collars[i,1]) < 1e-6:
            cut_planes[i] = 101
        elif abs(quad_collars[i,1]) < 1e-6:
            cut_planes[i] = 102
        elif abs(quad_collars[i,0]) < 1e-6:
            cut_planes[i] = 103
        else:
            cut_planes[i] = 104
        for j in range(bhe_collars.shape[0]):
            if distance_between_points(quad_collars[i,:], bhe_collars[j,:]) < 1e-6:
                if bhe_counts[j] == 4:
                    bhe_factors[i] = 1
                elif bhe_counts[j] == 2:
                    bhe_factors[i] = 2
                elif bhe_counts[j] == 1:
                    bhe_factors[i] = 4
                else:
                    raise SystemExit("Invalid BHE count.")
    ax.view_init(azim=0, elev=90)
    ax.set_xlabel("x")
    ax.set_ylabel("y")
    ax.set_zlabel("z")
    show()
    return quad_collars, quad_footers, bhe_factors, cut_planes

def make_hemispherical_bhe_axes(type, level):
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

def make_hemispherical_bhe_field(bhe_axes, bhe_offset, bhe_length, tunnel_depth):
    tunnel_offset = array([0, 0, -tunnel_depth])
    bhe_collars = bhe_offset * bhe_axes + tunnel_offset
    bhe_footers = (bhe_offset + bhe_length) * bhe_axes + tunnel_offset
    return bhe_collars, bhe_footers

def make_rectangular_bhe_field(dx, dy, nx, ny, bhe_length):
    x = linspace(-0.5*dx, +0.5*dx, nx)
    y = linspace(-0.5*dy, +0.5*dy, ny)
    print("Rectangular field")
    print("Horizontal spacing = %f x %f" % (x[1]-x[0], y[1]-y[0]))
    x, y = meshgrid(x, y)
    x = ravel(x)
    y = ravel(y)
    bhe_collars = zeros((len(x), 3))
    bhe_footers = zeros((len(x), 3))
    bhe_collars[:, 0] = x
    bhe_collars[:, 1] = y
    bhe_collars[:, 2] = 0.0
    bhe_footers[:, 0] = x
    bhe_footers[:, 1] = y
    bhe_footers[:, 2] = -bhe_length
    return bhe_collars, bhe_footers

def plot_bhe_field(bhe_collars, bhe_footers, plot_title):
    fig = figure()
    ax = Axes3D(fig)
    for i in range(bhe_collars.shape[0]):
        ax.plot([bhe_collars[i,0],bhe_footers[i,0]], [bhe_collars[i,1],bhe_footers[i,1]], [bhe_collars[i,2],bhe_footers[i,2]], "r-")
        ax.plot([bhe_collars[i,0]], [bhe_collars[i,1]], [bhe_collars[i,2]], "b.")
        ax.plot([bhe_footers[i,0]], [bhe_footers[i,1]], [bhe_footers[i,2]], "r.")
    title("%s (%d BHEs)" % (plot_title, bhe_collars.shape[0]))
    ax.set_xlabel("x")
    ax.set_ylabel("y")
    ax.set_zlabel("z")

def write_bhe_field(txt_name, bhe_collars, bhe_footers, bhe_factors, cut_planes):
    sx, sy, sz = bhe_collars.T
    ex, ey, ez = bhe_footers.T
    file = open(txt_name, "w")
    for i in range(len(bhe_factors)):
        file.write("%+12.6f %+12.6f %+12.6f %+12.6f %+12.6f %+12.6f %6d %6d\n" % (sx[i], sy[i], sz[i], ex[i], ey[i], ez[i], bhe_factors[i], cut_planes[i]))
    file.close()

bhe_axes = make_hemispherical_bhe_axes("ico", 1)
bhe_collars0, bhe_footers0 = make_hemispherical_bhe_field(bhe_axes, 50, 100, 100)

#bhe_collars0, bhe_footers0 = make_rectangular_bhe_field(300, 500, 7, 9, 300)

bhe_collars, bhe_footers, bhe_factors, cut_planes = quarter_symmetry(bhe_collars0, bhe_footers0)

print("Total number of BHEs:    %d" % bhe_collars0.shape[0])
print("Sum of BHE factors:      %d" % sum(bhe_factors))
print("Number of quadrant BHEs: %d" % bhe_collars.shape[0])

if sum(bhe_factors) != bhe_collars0.shape[0]:
    print("Result:                  asymmetry")
    raise SystemExit("Asymmetry!")
else:
    print("Result:                  symmetry")

write_bhe_field("test.txt", bhe_collars, bhe_footers, bhe_factors, cut_planes)

plot_bhe_field(bhe_collars, bhe_footers, "BHE Field")

show()
