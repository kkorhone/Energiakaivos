from mpl_toolkits.mplot3d import Axes3D
from scipy.optimize import leastsq
from pylab import *

def plane(x, y, p):
    return p[0] * x + p[1] * y + p[2]

file = open("graniitti.txt", "rt")

x, y, k = [], [], []

for line in file:
    toks = line.strip().split()
    x.append(float(toks[2]))
    y.append(float(toks[3]))
    k.append(float(toks[5]))

file.close()

x, y, k = array(x), array(y), array(k)

i = [0, 1, 3, 6, 7, 8, 9, 10, 11, 12, 14, 15, 17]
x, y, k = x[i], y[i], k[i]

p1 = leastsq(lambda p: plane(x,y,p)-k, [0,0,mean(k)])[0]

xi = linspace(min(x), max(x), 10)
yi = linspace(min(y), max(y), 10)

xi, yi = meshgrid(xi, yi)

ki = plane(xi, yi, p1)

e1 = plane(x, y, p1) - k

i = find((-0.4 <= e1) & (e1 <= +0.4))

p2 = leastsq(lambda p: plane(x[i],y[i],p)-k[i], [0,0,mean(k[i])])[0]

fig = plt.figure()

ax = fig.add_subplot(111, projection='3d')

ax.plot(x, y, k, "b.")
ax.plot(x[i], y[i], k[i], "r.")
ax.scatter(xi, yi, plane(xi,yi,p1), "r-")
ax.scatter(xi, yi, plane(xi,yi,p2), "r-")

print e1
print plane(x[i],y[i],p2)-k[i]

show()
