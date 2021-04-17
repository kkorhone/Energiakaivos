from mpl_toolkits.mplot3d import Axes3D
import statsmodels.api as sm
from pylab import *

def fit_plane(x, y, z):
    xm, ym = x-mean(x), y-mean(y)
    X = sm.add_constant(vstack((xm, ym)).T)
    model = sm.OLS(z, X)
    results = model.fit()
    print(results.summary())

#x, y, rho, k, Cp, alpha = loadtxt(r"E:\Work\Helsingin_Geoenergiapotentiaali\Thermal_Properties\amphibolite.txt", skiprows=1).T
#x, y, rho, k, Cp, alpha = loadtxt(r"E:\Work\Helsingin_Geoenergiapotentiaali\Thermal_Properties\feldspar.txt", skiprows=1).T
#x, y, rho, k, Cp, alpha = loadtxt(r"E:\Work\Helsingin_Geoenergiapotentiaali\Thermal_Properties\gabbro.txt", skiprows=1).T
#x, y, rho, k, Cp, alpha = loadtxt(r"E:\Work\Helsingin_Geoenergiapotentiaali\Thermal_Properties\granite.txt", skiprows=1).T
#x, y, rho, k, Cp, alpha = loadtxt(r"E:\Work\Helsingin_Geoenergiapotentiaali\Thermal_Properties\granodiorite.txt", skiprows=1).T
#x, y, rho, k, Cp, alpha = loadtxt(r"E:\Work\Helsingin_Geoenergiapotentiaali\Thermal_Properties\mica.txt", skiprows=1).T

x1, y1, rho1, k1, Cp1, alpha1 = loadtxt(r"E:\Work\Helsingin_Geoenergiapotentiaali\Thermal_Properties\amphibolite.txt", skiprows=1).T
x2, y2, rho2, k2, Cp2, alpha2 = loadtxt(r"E:\Work\Helsingin_Geoenergiapotentiaali\Thermal_Properties\feldspar.txt", skiprows=1).T
x3, y3, rho3, k3, Cp3, alpha3 = loadtxt(r"E:\Work\Helsingin_Geoenergiapotentiaali\Thermal_Properties\gabbro.txt", skiprows=1).T
x4, y4, rho4, k4, Cp4, alpha4 = loadtxt(r"E:\Work\Helsingin_Geoenergiapotentiaali\Thermal_Properties\granite.txt", skiprows=1).T
x5, y5, rho5, k5, Cp5, alpha5 = loadtxt(r"E:\Work\Helsingin_Geoenergiapotentiaali\Thermal_Properties\granodiorite.txt", skiprows=1).T
x6, y6, rho6, k6, Cp6, alpha6 = loadtxt(r"E:\Work\Helsingin_Geoenergiapotentiaali\Thermal_Properties\mica.txt", skiprows=1).T

x = hstack((x1, x2, x3, x4, x5, x6))
y = hstack((y1, y2, y3, y4, y5, y6))
rho = hstack((rho1, rho2, rho3, rho4, rho5, rho6))
k = hstack((k1, k2, k3, k4, k5, k6))
Cp = hstack((Cp1, Cp2, Cp3, Cp4, Cp5, Cp6))
alpha = hstack((alpha1, alpha2, alpha3, alpha4, alpha5, alpha6))

print("R"*50); fit_plane(x, y, rho)
print("K "*50); fit_plane(x, y, k)
print("C "*50); fit_plane(x, y, Cp)
print("A "*50); fit_plane(x, y, alpha)

fig = plt.figure()

ax = fig.add_subplot(221, projection="3d"); ax.plot(x, y, rho, "ro"); title("rho")
ax = fig.add_subplot(222, projection="3d"); ax.plot(x, y, k, "go"); title("k")
ax = fig.add_subplot(223, projection="3d"); ax.plot(x, y, Cp, "bo"); title("Cp")
ax = fig.add_subplot(224, projection="3d"); ax.plot(x, y, alpha, "co"); title("alpha")

show()
