from mpl_toolkits.mplot3d import Axes3D
from pandas import *
from pylab import *

data = read_excel("random_sample_99.xlsx")

x = array(data["x"])
y = array(data["y"])
E = array(data["E_block"])

data = read_excel("random_sample_467.xlsx")

_x = hstack((x, data["x"]))
_y = hstack((y, data["y"]))
_E = hstack((E, data["E_block"]))

xy = list(set(["%.4f %.4f" % (_x, _y) for _x, _y in zip(x, y)]))

print len(x), len(xy)

plot(x, y, "r.")
show()
