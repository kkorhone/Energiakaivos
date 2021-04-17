from mpl_toolkits.mplot3d import Axes3D
from pylab import *

E, B, T = loadtxt("test.txt").T

fig = plt.figure()

ax = fig.add_subplot(111, projection="3d")

ax.scatter(E, B, log(T))

show()
