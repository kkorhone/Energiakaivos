from scipy.integrate import trapz
from pylab import *

# -------------------------------------------------------------------
# Loads data.
# -------------------------------------------------------------------

data1 = loadtxt("fluxes_300m_20m.txt")
data2 = loadtxt("fluxes_300m_500m.txt")

t1 = data1[:, 0]
t2 = data2[:, 0]

Q_wall1 = data1[:, 1]
Q_surf1 = data1[:, 2]

Q_wall2 = data2[:, 1]
Q_surf2 = data2[:, 2]

# -------------------------------------------------------------------
# Calculates annual average heat rates.
# -------------------------------------------------------------------

t_avg1, Q_wall_avg1, Q_surf_avg1 = [], [], []
t_avg2, Q_wall_avg2, Q_surf_avg2 = [], [], []

for year in range(50):
    i = where(((year-0.001) <= t1) & (t1 <= (year+1.001)))[0]
    t_avg1.append(mean(t1[i]))
    Q_wall_avg1.append(mean(Q_wall1[i]))
    Q_surf_avg1.append(mean(Q_surf1[i]))

for year in range(50):
    i = where(((year-0.001) <= t2) & (t2 <= (year+1.001)))[0]
    t_avg2.append(mean(t2[i]))
    Q_wall_avg2.append(mean(Q_wall2[i]))
    Q_surf_avg2.append(mean(Q_surf2[i]))

t_avg1, Q_wall_avg1, Q_surf_avg1 = array(t_avg1), array(Q_wall_avg1), array(Q_surf_avg1)
t_avg2, Q_wall_avg2, Q_surf_avg2 = array(t_avg2), array(Q_wall_avg2), array(Q_surf_avg2)

# -------------------------------------------------------------------
# Calculates cumulative energies.
# -------------------------------------------------------------------

E_wall_cum1, E_surf_cum1 = [], []
E_wall_cum2, E_surf_cum2 = [], []

for i in range(len(t1)):
    E_wall_cum1.append(trapz(Q_wall1[:i], t1[:i]))
    E_surf_cum1.append(trapz(Q_surf1[:i], t1[:i]))

for i in range(len(t2)):
    E_wall_cum2.append(trapz(Q_wall2[:i], t2[:i]))
    E_surf_cum2.append(trapz(Q_surf2[:i], t2[:i]))

E_wall_cum1, E_surf_cum1 = array(E_wall_cum1), array(E_surf_cum1)
E_wall_cum2, E_surf_cum2 = array(E_wall_cum2), array(E_surf_cum2)

# -------------------------------------------------------------------
# Plots heat rates.
# -------------------------------------------------------------------

a = where(t1 >= 1)[0]
b = where(t2 >= 1)[0]

# fig = figure()
# ax = axes([0.125, 0.225, 0.85, 0.75])
# plot(t, Q_wall, "r-", lw=1, label="Heat extraction rate through borehole wall")
# plot(t, Q_surf, "b-", lw=1, label="Downward heat rate through ground surface")
# xlabel("Time [a]")
# ylabel("Heat rate [W]")
# ax.set_xlim([0, 50])
# ax.set_ylim([0, 2250])
# figlegend(loc="lower center")
# ax.grid()

# -------------------------------------------------------------------
# Plots percentages.
# -------------------------------------------------------------------

fig = figure()
ax = axes([0.125, 0.225, 0.85, 0.75])
plot(t_avg1, Q_surf_avg1*100/Q_wall_avg1, "r-", lw=1, label="Heat rates")
plot(t_avg2, Q_surf_avg2*100/Q_wall_avg2, "r--", lw=1, label="Heat rates")
plot(t1[a], E_surf_cum1[a]*100/E_wall_cum1[a], "b-", lw=1, label="Cumulative energies")
plot(t2[b], E_surf_cum2[b]*100/E_wall_cum2[b], "b--", lw=1, label="Cumulative energies")
xlabel("Time [a]")
ylabel("Ground surface to borehole wall ratio [%]")
ax.set_xlim([0, 50])
#ax.set_ylim([0, 20])
figlegend(loc="lower center")
ax.grid()

show()
