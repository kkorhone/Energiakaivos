from pylab import *

T0, z0 = loadtxt("pys_35.txt").T
T1, z1 = loadtxt("ph_101.txt").T
T2, z2 = loadtxt("r_2234.txt").T
T3, z3 = loadtxt("r_2243.txt").T
T4, z4 = loadtxt("r_2245.txt").T

T0 -= 0.35

i0 = range(100, len(T0))
i1 = range(50, len(T1))
i2 = range(150, len(T2))
i3 = range(150, len(T3))
i4 = range(50, len(T4))

z = hstack((z0[i0], z2[i2], z3[i3]))
T = hstack((T0[i0], T2[i2], T3[i3]))

#plot(T0, z0, "b.")
#plot(T0[i0], z0[i0], "r.")

##plot(T1, z1, "b.")
##plot(T1[i1], z1[i1], "r.")

#plot(T2, z2, "b.")
#plot(T2[i2], z2[i2], "c.")

#plot(T3, z3, "b.")
#plot(T3[i3], z3[i3], "c.")

##plot(T4[i4], z4[i4], "c.")
##plot(T4, z4, "b.")

#p = polyfit(z, T, 1)

#print(p[0], p[1])

#plot(T, z, "b.")
#plot(polyval(p, z), z, "r-")

p0 = polyfit(z0[i0], T0[i0], 1)

plot(T0[i0], z0[i0], "b.")
plot(polyval(p0, z0), z0, "r-")

gca().set_ylim(gca().get_ylim()[::-1])

show()
