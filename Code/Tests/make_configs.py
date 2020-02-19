from mpl_toolkits.mplot3d import Axes3D
from collections import OrderedDict
import meshzoo as mz
from pylab import *

def distance_between_points(p1, p2):
    dx = p1[0] - p2[0]
    dy = p1[1] - p2[1]
    dz = p1[2] - p2[2]
    return sqrt(dx**2 + dy**2 + dz**2)

def test_for_symmetry(points):
    
    # Finds all points in the first quandrant.
    
    k = []
    
    for i in range(points.shape[0]):
        if abs(points[i, 0]) < 1e-6 and abs(points[i, 1]) < 1e-6:
            k.append(i)
        if abs(points[i, 0]) < 1e-6 and points[i, 1] >= 0:
            k.append(i)
        elif points[i, 0] >= 0 and abs(points[i, 1]) < 1e-6:
            k.append(i)
        elif points[i, 0] >=0 and points[i, 1] >= 0:
            k.append(i)
            
    # Points in the first quadrant.
    
    p1 = points[k, :]
    
    # Mirror against the x axis.
    
    p2 = vstack((-p1[:,0], p1[:,1], p1[:,2])).T
    
    # Mirrored points in the first and second quadrants.
    
    p3 = vstack((p1, p2))
    
    # Mirror against the y axis.
    
    p4 = vstack((p3[:,0], -p3[:,1], p3[:,2])).T
    
    # Mirrored points in all quadrants.
    
    p5 = vstack((p3, p4))
    
    # Tests for the results.
    
    # Plots the results.

    figure()    
    plot(p5[:,0], p5[:,1], "ro", mfc="w")
    plot(points[:,0], points[:,1], "c.")
    
    bag = []
    for i in range(points.shape[0]):
        k = -1
        for j in range(p5.shape[0]):
            if distance_between_points(points[i, :], p5[j, :]) < 1e-6:
                k = j
        if k >= 0:
            bag.append(k)
    
    if len(bag) == points.shape[0]:
        title("Symmetry (%d points)" % points.shape[0])
    else:
        title("Asymmetry (%d points)" % (points.shape[0]-len(bag)))
    
def make_config(type):
    if type == "ico":
        points, cells = mz.icosa_sphere(2) # 25
        #points, cells = mz.icosa_sphere(4) # 89
        #points, cells = mz.icosa_sphere(5) # 136
        #points, cells = mz.icosa_sphere(8) # 337
    elif type == "uv":
        points, cells = mz.uv_sphere(num_points_per_circle=13, num_circles=15)
        #points, cells = mz.uv_sphere(num_points_per_circle=6, num_circles=9) # 25 BHEs
        #points, cells = mz.uv_sphere(num_points_per_circle=12, num_circles=15) # 85 BHEs
        #points, cells = mz.uv_sphere(num_points_per_circle=18, num_circles=17) # 145 BHEs
        #points, cells = mz.uv_sphere(num_points_per_circle=26, num_circles=27) # 339 BHEs
    else:
        raise ValueError("Config type must be 'ico' or 'uv'.")
    i = where(points[:,2] <= 0)[0]
    return points[i]

def plot_config(type, points):
    fig = figure()
    ax = Axes3D(fig)
    ax.scatter(points[:,0], points[:,1], points[:,2], "b.")
    for i in range(points.shape[0]):
        ax.plot([0, points[i,0]], [0, points[i,1]], [0, points[i,2]], "r-")
    ax.view_init(azim=0, elev=90)
    title("%d BHEs (%s)" % (points.shape[0], type))

def make_field(points, offset, length):
    nx = points[:, 0] / sqrt(points[:,0]**2+points[:,1]**2+points[:,2]**2)
    ny = points[:, 1] / sqrt(points[:,0]**2+points[:,1]**2+points[:,2]**2)
    nz = points[:, 2] / sqrt(points[:,0]**2+points[:,1]**2+points[:,2]**2)
    sx = offset * nx
    sy = offset * ny
    sz = offset * nz
    ex = (offset + length) * nx
    ey = (offset + length) * ny
    ez = (offset + length) * nz
    return vstack((sx, sy, sz)).T, vstack((ex, ey, ez)).T

def plot_field(starting_points, ending_points):
    sx, sy, sz = starting_points.T
    ex, ey, ez = ending_points.T
    fig = figure()
    ax = Axes3D(fig)
    for i in range(starting_points.shape[0]):
        ax.plot([sx[i],ex[i]], [sy[i],ey[i]], [sz[i],ez[i]], "r-")
        ax.plot([sx[i]], [sy[i]], [sz[i]], "r.")
        ax.plot([ex[i]], [ey[i]], [ez[i]], "ro")

def write_field(txt_name, starting_points, ending_points):
    sx, sy, sz = starting_points.T
    ex, ey, ez = ending_points.T
    file = open(txt_name, "w")
    for i in range(starting_points.shape[0]):
        file.write("%.20f %.20f %.20f %.20f %.20f %.20f\n" % (sx[i], sy[i], sz[i], ex[i], ey[i], ez[i]))
    file.close()

points = make_config("ico")
starting_points, ending_points = make_field(points, 50, 300)
plot_field(starting_points, ending_points)
test_for_symmetry(points)
plot_config("ico", points)
write_field("ico_field.txt", starting_points, ending_points)

points = make_config("uv")
starting_points, ending_points = make_field(points, 50, 300)
plot_field(starting_points, ending_points)
test_for_symmetry(points)
plot_config("uv", points)
write_field("uv_field.txt", starting_points, ending_points)

show()
