from pylab import *

t0, T0 = loadtxt("graniitti_default.txt", skiprows=8).T
t1, T1 = loadtxt("graniitti_hires.txt", skiprows=8).T
t2, T2 = loadtxt("graniitti_hitime.txt", skiprows=8).T

a = find(t0 > 49)
b = find(t1 > 49)
c = find(t2 > 49)

plot(t0[a], T0[a])
plot(t1[b], T1[b])
plot(t2[c], T2[c])

print min(T0[a])
print min(T1[b])
print min(T2[c])

show()
