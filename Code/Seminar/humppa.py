from scipy.integrate import trapz, cumtrapz
from pylab import *

data = loadtxt("recovery.txt", skiprows=8)

num_times = int(data.shape[0] / 4)

t = data[:num_times, 0]

i = where(t <= 100)[0]
j = where(t > 100)[0]

Q_total = data[0*num_times:1*num_times, 1]
Q_above = data[1*num_times:2*num_times, 1]
Q_below = data[2*num_times:3*num_times, 1]
T_field = data[3*num_times:4*num_times, 1]

E_total = trapz(Q_total[i]*1e-9, t[i]*365.2425*24)
E_outside = trapz((Q_above[i]+Q_below[i])*1e-9, t[i]*365.2425*24)
E_inside = trapz((Q_total[i]-Q_above[i]-Q_below[i])*1e-9, t[i]*365.2425*24)

E1 = cumtrapz((Q_above[j]+Q_below[j])*1e-9, t[j]*365.2425*24)
E2 = cumtrapz(Q_above[j]*1e-9, t[j]*365.2425*24)
E3 = cumtrapz(Q_below[j]*1e-9, t[j]*365.2425*24)

ax1 = gca()
semilogx(t[j[1:]], E1, "r-")
#semilogx(t[j[1:]], E2, "g-")
#semilogx(t[j[1:]], E3, "b-")
axhline(611, ls="--", color="r", lw=1)

ax2 = twinx()
semilogx(t[j[1:]], T_field[j[1:]], "b-")
axhline(T_field[0], ls="--", color="b", lw=1)

ax1.set_xlim([1e2, 1e6])
ax2.set_xlim([1e2, 1e6])

#ax1.set_ylim([0, 700])
#ax2.set_ylim([0, 24])

show()

#plot(t[i], Q_total[i])
#show()
