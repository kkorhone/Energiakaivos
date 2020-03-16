from meshzoo import icosa_sphere, uv_sphere
from mpl_toolkits.mplot3d import Axes3D
from scipy.optimize import brute
from pylab import *

def distance_between_points(p1, p2):
    return sqrt((p1[0]-p2[0])**2+(p1[1]-p2[1])**2+(p1[2]-p2[2])**2)

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
    # Determines the BHE factors.
    bhe_factors = ones(quad_collars.shape[0])
    for i in range(quad_collars.shape[0]):
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
    # Print some info.
    print("Total number of BHEs:    %d" % bhe_collars.shape[0])
    print("Sum of BHE factors:      %d" % sum(bhe_factors))
    print("Number of quadrant BHEs: %d" % quad_collars.shape[0])
    if sum(bhe_factors) != bhe_collars.shape[0]:
        print("Result:                  asymmetry")
    else:
        print("Result:                  symmetry")
    return quad_collars, quad_footers, bhe_factors

def make_hemispherical_bhe_field(bhe_axes, bhe_offset, bhe_length, field_depth):
    print("Hemispherical BHE field: N=%d" % bhe_axes.shape[0])
    vertical_offset = array([0, 0, -field_depth])
    bhe_collars = bhe_offset * bhe_axes + vertical_offset
    bhe_footers = (bhe_offset + bhe_length) * bhe_axes + vertical_offset
    return bhe_collars, bhe_footers

def make_rectangular_bhe_field(field_width, field_height, nx, ny, bhe_length, field_depth):
    x = linspace(-0.5*field_width, +0.5*field_width, nx)
    y = linspace(-0.5*field_height, +0.5*field_height, ny)
    dx, dy = x[1] - x[0], y[1] - y[0]
    x, y = meshgrid(x, y)
    x = ravel(x)
    y = ravel(y)
    print("Rectangular BHE field: N=%d dx=%.3f dy=%.3f" % (length(x), dx, dy))
    bhe_collars = zeros((len(x), 3))
    bhe_footers = zeros((len(x), 3))
    bhe_collars[:, 0] = x
    bhe_collars[:, 1] = y
    bhe_collars[:, 2] = -field_depth
    bhe_footers[:, 0] = x
    bhe_footers[:, 1] = y
    bhe_footers[:, 2] = -field_depth-bhe_length
    return bhe_collars, bhe_footers

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

def write_bhe_field(txt_name, bhe_collars, bhe_footers, bhe_factors):
    sx, sy, sz = bhe_collars.T
    ex, ey, ez = bhe_footers.T
    file = open(txt_name, "w")
    for i in range(len(bhe_factors)):
        file.write("%+12.6f %+12.6f %+12.6f %+12.6f %+12.6f %+12.6f %6d\n" % (sx[i], sy[i], sz[i], ex[i], ey[i], ez[i], bhe_factors[i]))
    file.close()

def make_ico_axes(level):
    bhe_axes, _ = icosa_sphere(level)
    i = where(bhe_axes[:, 2] <= 0)[0]
    return bhe_axes[i]

def make_uv_axes(nppc, nc):
    bhe_axes, _ = uv_sphere(num_points_per_circle=nppc, num_circles=nc)
    i = where(bhe_axes[:, 2] <= 0)[0]
    return bhe_axes[i]

def find_uv_params(n):
    diff_data = {0:[], 1:[], 2:[], 3:[], 4:[], 5:[]}
    for nppc in range(4, 50):
        for nc in range(4, 50):
            bhe_axes = make_uv_axes(nppc, nc)
            num_diff = abs(bhe_axes.shape[0] - n)
            if num_diff <= 5:
                diff_data[num_diff].append([nppc, nc])
    return diff_data

def write_ico_uv_params(file_name):
    file = open(file_name, "w")
    for level in range(1, 11):
        bhe_axes = make_ico_axes(level)
        file.write("ico: level=%d N=%d\n" % (level, bhe_axes.shape[0]))
        diff_data = find_uv_params(bhe_axes.shape[0])
        for i in range(6):
            file.write(" -> uv: diff=%d pars=%s\n" % (i, str(diff_data[i])))
        file.write("\n")
    file.close()

#write_ico_uv_params("ico_uv_params.txt")

#bhe_collars0, bhe_footers0 = make_rectangular_bhe_field(100, 100, 5, 5, 300)

# Ico field levels that produce symmetric BHE fields: 1, 2, 4, 5, 8 and 10.

# ----------------   -----------------------
#    Ico Fields             Uv Fields
# ----------------   -----------------------
# Level Quad Total   Nppc Nc Quad Total Diff
# ----------------   -----------------------
#     1    3     8      4  5    5     9    1
#     2    9    25      8  7   10    25    0
#     4   27    89     18 11   26    91    2
#     5   39   136     20 15   43   141    5
#     8   93   337     28 25   97   337    0
#    10  141   521     40 27  144   521    0
# ----------------   -----------------------

def make_ico_field(level):
    bhe_axes = make_ico_axes(level)
    bhe_collars0, bhe_footers0 = make_hemispherical_bhe_field(bhe_axes, 30, 100, 100)
    bhe_collars, bhe_footers, bhe_factors = quarter_symmetry(bhe_collars0, bhe_footers0)
    write_bhe_field("ico_field_%d.txt"%sum(bhe_factors), bhe_collars, bhe_footers, bhe_factors)
    plot_bhe_field(bhe_collars, bhe_footers, "Ico Field %d" % sum(bhe_factors))
    show()

def make_uv_field(nppc, nc):
    bhe_axes = make_uv_axes(nppc, nc)
    bhe_collars0, bhe_footers0 = make_hemispherical_bhe_field(bhe_axes, 10, 300, 1450)
    bhe_collars, bhe_footers, bhe_factors = quarter_symmetry(bhe_collars0, bhe_footers0)
    write_bhe_field("uv_field_%d.txt"%sum(bhe_factors), bhe_collars, bhe_footers, bhe_factors)
    plot_bhe_field(bhe_collars, bhe_footers, "UV Field %d" % sum(bhe_factors))
    show()

def make_test_field(borehole_tilts, sector_angle):
    borehole_tilts = sorted(borehole_tilts)
    num_sectors = int(360.0 / sector_angle)
    if borehole_tilts[0] == -90:
        num_bhes = 1 + (len(borehole_tilts) - 1) * num_sectors
    else:
        num_bhes = len(borehole_tilts) * num_sectors
    bhe_axes = zeros((num_bhes, 3))
    k = 0
    for i in range(len(borehole_tilts)):
        if borehole_tilts[i] == -90:
            bhe_axes[k,:] = [0, 0, -1]
            k += 1
        else:
            theta = radians(borehole_tilts[i])
            for j in range(num_sectors):
                phi = radians(j * sector_angle)
                bhe_axes[k,:] = [cos(theta)*cos(phi), cos(theta)*sin(phi), sin(theta)]
                k += 1
    bhe_collars0, bhe_footers0 = make_hemispherical_bhe_field(bhe_axes, 30, 300, 1450)
    bhe_collars, bhe_footers, bhe_factors = quarter_symmetry(bhe_collars0, bhe_footers0)
    write_bhe_field("test_field_%d.txt"%sum(bhe_factors), bhe_collars, bhe_footers, bhe_factors)
    plot_bhe_field(bhe_collars, bhe_footers, "UV Field %d" % sum(bhe_factors))
    show()

#make_ico_field(10)
#make_uv_field(20, 15)
make_test_field([-90, -75, -60, -45, -30, -15, 0], 30)
