from mpl_toolkits.mplot3d import Axes3D
from pylab import *

data1 = loadtxt("full_ico_solved.txt", skiprows=9)
data2 = loadtxt("quarter_ico_solved.txt", skiprows=9)

print(data1.shape)
print(data2.shape)

x1, y1, z1, T1 = data1[:, :4].T
x2, y2, z2, T2 = data2[:, :4].T

#ax = Axes3D(figure())

#ax.scatter(x1-x2, y1-y2, z1-z2, "r.")

plot(T1-T2)

show()
