from pylab import *

T = loadtxt("ground_surface_temperature_intersect.txt")
q = loadtxt("geothermal_heat_flux_intersect.txt")

def mode(x, num_bins=100):
    n, b = histogram(x, bins=num_bins)
    i = find(n == max(n))[0]
    return 0.5 * (b[i] + b[i+1])

for n in [50, 100, 150, 200, 250, 300, 350, 400, 450, 500]:
    T_mode = mode(T, num_bins=n)
    q_mode = mode(q, num_bins=n)
    print "%3d %.3f %.3f" % (n, T_mode, q_mode)

T_mode = 6.762
q_mode = 40.666

figure()
hist(T, 100)
axvline(T_mode, color="r", lw=3)

figure()
hist(q, 100)
axvline(q_mode, color="r", lw=3)

show()
