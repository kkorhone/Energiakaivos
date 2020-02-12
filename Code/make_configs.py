from mpl_toolkits.mplot3d import Axes3D
import meshzoo as mz
from pylab import *

def make_config(type):
    if type == "ico":
        #points, cells = mz.icosa_sphere(2) # 25 BHEs symm
        #points, cells = mz.icosa_sphere(3) # 50 BHEs asymm
        points, cells = mz.icosa_sphere(4) # 89 BHEs symm
    elif type == "uv":
        #points, cells = mz.uv_sphere(num_points_per_circle=6, num_circles=9) # 25 BHEs
        #points, cells = mz.uv_sphere(num_points_per_circle=12, num_circles=10) # 49 BHEs
        points, cells = mz.uv_sphere(num_points_per_circle=12, num_circles=15) # 85 BHEs
    else:
        raise ValueError("Config type must be 'ico' or 'uv'.")
    i = where(points[:,2] <= 0)[0]
    return points[i]

def plot_config(type, points):
    ax = Axes3D(figure())
    for i in range(points.shape[0]):
        ax.plot([0, points[i,0]], [0, points[i,1]], [0, points[i,2]], "r-")
    ax.scatter(points[:,0], points[:,1], points[:,2], "r")
    ax.view_init(azim=0, elev=90)
    title("%d BHEs (%s)" % (points.shape[0], type))

points = make_config("ico")
plot_config("ico", points)
savetxt("ico_config.txt", points)

points = make_config("uv")
plot_config("uv", points)
savetxt("uv_config.txt", points)

show()
