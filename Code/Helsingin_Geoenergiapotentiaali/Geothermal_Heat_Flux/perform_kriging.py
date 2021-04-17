from pykrige.ok import OrdinaryKriging

from pylab import *
import semivariance

def custom_variogram_model(params, h):
    semivariance = polyval(params, h)
    semivariance[h>=350000] = polyval(params, 350000)
    return semivariance

x, y, A = loadtxt("heat_production_clipped.txt").T

lags = linspace(0, 400000, 100)

h, gamma = semivariance.calculate(x, y, A, lags)

p = polyfit(h, gamma, 7)

params = [5.33414815575e-37, -7.81514348589e-31, 4.5474276966e-25, -1.32985748789e-19, 2.04626451705e-14, -1.62134643867e-09, 6.4300696071e-05, -0.139352293189]

#for i in range(len(p)): print i, p[i]
#plot(h, gamma, "*-")
#plot(h, polyval(p,h), "r-", lw=3)
#plot(linspace(0, 1000000, 100), custom_variogram_model(params, linspace(0, 1000000, 100)), "r-", lw=3)
#show()
#raise SystemExit

xp, yp = loadtxt(r"E:\Work\Helsingin_Geoenergiapotentiaali\Map_Points\map_points.txt").T

#OK = OrdinaryKriging(x, y, A, variogram_model="power", nlags=6, verbose=True, enable_plotting=True)
#OK = OrdinaryKriging(x, y, A, variogram_model="custom", variogram_function=custom_variogram_model, variogram_parameters=params, nlags=100, verbose=True, enable_plotting=True)
OK = OrdinaryKriging(x, y, A, variogram_model="exponential", nlags=6, verbose=False, enable_plotting=True)
raise SystemExit

def krige_grid(x, y, A):

    cell_size = 1000
    chunk_size = 10

    xi = arange(min(x), max(x)+cell_size, cell_size)
    yi = arange(min(y), max(y)+cell_size, cell_size)

    num_rows, num_cols = len(yi), len(xi)

    xi, yi = meshgrid(xi, yi)

    Ai = zeros_like(xi)
    si = zeros_like(xi)

    rows = unique(hstack((arange(0, xi.shape[0], chunk_size), Ai.shape[0])))

    for i in range(len(rows)-1):
        j = range(rows[i], rows[i+1])
        _x = xi[j,:].reshape(len(j)*num_cols, 1)
        _y = yi[j,:].reshape(len(j)*num_cols, 1)
        _A, _s = OK.execute("points", _x, _y)
        Ai[j,:] = _A.reshape(len(j), num_cols)
        si[j,:] = _s.reshape(len(j), num_cols)
        print "Done %.1f %%." % ((i + 1) * 100.0 / (len(rows)-1))

    return xi, yi, Ai, si

def krige_points(x, y, A, xp, yp):

    chunk_size = 100

    Ap = zeros_like(xp)
    sp = zeros_like(xp)

    cols = unique(hstack((arange(0, len(xp), chunk_size), len(xp))))

    for i in range(len(cols)-1):
        j = range(cols[i], cols[i+1])
        Ap[j], sp[j] = OK.execute("points", xp[j], yp[j])
        print "Done %.1f %%." % ((i + 1) * 100.0 / (len(cols)-1))

    return xp, yp, Ap, sp

figure()
scatter(x, y, c=A, cmap="jet", s=40, marker="s")
colorbar()
tight_layout()
axis("equal")

#xi, yi, Ai, si = krige_grid(x, y, A)
#savetxt("predicted_heat_production.txt", vstack((xi.ravel(), yi.ravel(), Ai.ravel())).T, fmt="%.6f")

#figure()
#pcolor(xi, yi, Ai, cmap="jet")
#colorbar()
#tight_layout()
#axis("equal")

#show(); raise SystemExit

xp, yp, Ap, sp = krige_points(x, y, A, xp, yp)
savetxt("predicted_heat_production.txt", vstack((xp, yp, Ap)).T, fmt="%.6f")

figure()
scatter(xp, yp, c=Ap, cmap="jet", s=0.5, marker="s")
colorbar()
tight_layout()
axis("equal")

show()
