from mpl_toolkits.mplot3d import Axes3D
import pandas
from pylab import *

data_frame = pandas.read_excel("data.xlsx", sheet_name="Selected")

x = array(data_frame["x"])
y = array(data_frame["y"])
rho = array(data_frame["rho"])
k = array(data_frame["k"])
Cp = array(data_frame["Cp"])
alpha = array(data_frame["alpha"])
code = array(data_frame["code"])

data = []

for i in [0, 1, 2, 3, 4, 5]:
    j = find(code == i)
    Z = alpha[j]
    if len(Z) > 1:
        m, s = mean(Z), std(Z)
        j = find((m-s <= Z) & (Z <= m+s))
        Z = Z[j]
        if len(Z) > 1:
            data.append(Z)

print data

boxplot(data)
show()

raise SystemExit

colors = array(["r", "g", "b", "c", "m", "y", "k"])

xi = linspace(min(x), max(x), 100)
yi = linspace(min(y), max(y), 100)

xi, yi = meshgrid(xi, yi)

ki = griddata(x, y, k, xi, yi, interp="linear")

f = figure()
ax = f.add_subplot(111, projection="3d")
ax.scatter(x, y, rho, color=colors[code])
ax.set_title("rho")

f = figure()
ax = f.add_subplot(111, projection="3d")
ax.scatter(x, y, k, color=colors[code])
ax.set_title("k")

f = figure()
ax = f.add_subplot(111, projection="3d")
ax.scatter(x, y, Cp, color=colors[code])
ax.set_title("Cp")

f = figure()
ax = f.add_subplot(111, projection="3d")
ax.scatter(x, y, alpha, color=colors[code])
ax.set_title("alpha")

show()
