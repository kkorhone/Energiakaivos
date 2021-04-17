from pykrige.ok import OrdinaryKriging

from pylab import *
import semivariance

def custom_variogram_model(params, h):
    semivariance = polyval(params, h)
    semivariance[h>=1155000] = polyval(params, 1155000)
    return semivariance

x, y, Q, A = loadtxt("heat_flow_map_gk25.txt").T

lags = arange(0, 10000000, 10000)

h, gamma = semivariance.calculate(x, y, Q, lags)

p = polyfit(h, gamma, 7)

params = [
 2.76319921621e-40,
 -1.11102542415e-33,
 1.74484466949e-27,
 -1.35794014278e-21,
 5.49954276925e-16,
 -1.11721422903e-10,
 1.07402382942e-05,
 0.0456772655258,
]

#for i in range(len(p)): print i, p[i]
#plot(h, gamma, "*-")
#plot(h, polyval(p,h), "r-", lw=3)
#plot(arange(0, 1200000, 10000), custom_variogram_model(params, arange(0, 1200000, 10000)), "r-", lw=3)
#show()
#raise SystemExit

xp, yp = loadtxt(r"E:\Work\Helsingin_Geoenergiapotentiaali\Map_Points\map_points_gk25.txt").T

#OK = OrdinaryKriging(x, y, A, variogram_model="power", nlags=6, verbose=True, enable_plotting=True)
OK = OrdinaryKriging(x, y, Q, variogram_model="custom", variogram_function=custom_variogram_model, variogram_parameters=params, nlags=100, verbose=True, enable_plotting=True)
#OK = OrdinaryKriging(x, y, A, variogram_model="exponential", nlags=6, verbose=False, enable_plotting=True)
#raise SystemExit

def krige_grid(x, y, Q):

    cell_size = 2000
    chunk_size = 10

    xi = arange(min(x), max(x)+cell_size, cell_size)
    yi = arange(min(y), max(y)+cell_size, cell_size)

    num_rows, num_cols = len(yi), len(xi)

    xi, yi = meshgrid(xi, yi)

    Qi = zeros_like(xi)
    si = zeros_like(xi)

    rows = unique(hstack((arange(0, xi.shape[0], chunk_size), Qi.shape[0])))

    for i in range(len(rows)-1):
        j = range(rows[i], rows[i+1])
        _x = xi[j,:].reshape(len(j)*num_cols, 1)
        _y = yi[j,:].reshape(len(j)*num_cols, 1)
        _Q, _s = OK.execute("points", _x, _y)
        Qi[j,:] = _Q.reshape(len(j), num_cols)
        si[j,:] = _s.reshape(len(j), num_cols)
        print "Done %.1f %%." % ((i + 1) * 100.0 / (len(rows)-1))

    return xi, yi, Qi, si

def krige_points(x, y, Q, xp, yp):

    chunk_size = 100

    Qp = zeros_like(xp)
    sp = zeros_like(xp)

    cols = unique(hstack((arange(0, len(xp), chunk_size), len(xp))))

    for i in range(len(cols)-1):
        j = range(cols[i], cols[i+1])
        Qp[j], sp[j] = OK.execute("points", xp[j], yp[j])
        print "Done %.1f %%." % ((i + 1) * 100.0 / (len(cols)-1))

    return xp, yp, Qp, sp

figure()
scatter(x, y, c=Q, cmap="jet", s=40, marker="s")
colorbar()
tight_layout()
axis("equal")

xi, yi, Qi, si = krige_grid(x, y, Q)
savetxt("predicted_heat_production.txt", vstack((xi.ravel(), yi.ravel(), Qi.ravel())).T, fmt="%.6f")

figure()
pcolor(xi, yi, Qi, cmap="jet")
colorbar()
tight_layout()
axis("equal")

show(); raise SystemExit

xp, yp, Qp, sp = krige_points(x, y, Q, xp, yp)
savetxt("predicted_heat_production.txt", vstack((xp, yp, Qp)).T, fmt="%.6f")

figure()
scatter(xp, yp, c=Qp, cmap="jet", s=0.5, marker="s")
colorbar()
tight_layout()
axis("equal")

show()
