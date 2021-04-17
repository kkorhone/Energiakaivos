from pylab import *

T = loadtxt("daily_temperature.txt")
_Q = loadtxt("hourly_energy.txt")

Q = []

for i in range(366):
    print(_Q[i*24:(i+1)*24], "%.3f"%sum(_Q[i*24:(i+1)*24]))
    Q.append(sum(_Q[i*24:(i+1)*24]))

print("%.3f %.3f %.3f" % (min(Q), mean(Q), max(Q)))
print("%.3f %.3f %.3f" % (min(T), mean(T), max(T)))

T, Q = array(T), array(Q)

figure()
plot(T, "b-")
gca().set_ylim(gca().get_ylim()[::-1])
twinx()
plot(Q, "r-")
title("Observed")

i = where(T <= 10)[0]
i = range(len(T))
p = polyfit(T[i], Q[i], 1)

# p1 * x + p2 = y <=> p1 * x = y - p2 <=> x = (y - p2) / p1

Q0 = 0.08
T0 = (Q0 - p[1]) / p[0]

figure()
plot(T, Q, "g.")
plot(T[i], Q[i], "r.")
plot(T, polyval(p, T), "b-")
axhline(Q0, ls="--", color="k")
axvline(T0, ls="--", color="k")
gca().set_xlim([-25, 25])
gca().set_ylim([0, 0.8])
title("Correlation")

T0 = 21.1
_Q = zeros_like(Q)
i = where(T <= T0)[0]
_Q[i] = polyval(p, T[i])
i = where(T > T0)[0]
_Q[i] = Q0

figure()
plot(T, "b-")
gca().set_ylim(gca().get_ylim()[::-1])
twinx()
plot(_Q, "r-")
title("Predicted")

show()
