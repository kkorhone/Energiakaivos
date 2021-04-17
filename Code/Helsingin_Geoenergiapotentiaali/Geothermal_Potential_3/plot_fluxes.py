from scipy.integrate import trapz
from pylab import *

# -------------------------------------------------------------------
# Loads data.
# -------------------------------------------------------------------

data = loadtxt("fluxes_300m.txt")

t = data[:, 0]

Q_wall = data[:, 1]
Q_surf = data[:, 2]

# -------------------------------------------------------------------
# Calculates annual average heat rates.
# -------------------------------------------------------------------

t_avg, Q_wall_avg, Q_surf_avg = [], [], []

for year in range(50):
    i = where(((year-0.001) <= t) & (t <= (year+1.001)))[0]
    t_avg.append(mean(t[i]))
    Q_wall_avg.append(mean(Q_wall[i]))
    Q_surf_avg.append(mean(Q_surf[i]))

t_avg, Q_wall_avg, Q_surf_avg = array(t_avg), array(Q_wall_avg), array(Q_surf_avg)

# -------------------------------------------------------------------
# Calculates cumulative energies.
# -------------------------------------------------------------------

E_wall_cum, E_surf_cum = [], []

for i in range(len(t)):
    E_wall_cum.append(trapz(Q_wall[:i], t[:i]))
    E_surf_cum.append(trapz(Q_surf[:i], t[:i]))

E_wall_cum, E_surf_cum = array(E_wall_cum), array(E_surf_cum)

# -------------------------------------------------------------------
# Plots heat rates.
# -------------------------------------------------------------------

i = where(t >= 1)[0]

fig = figure()
ax = axes([0.125, 0.225, 0.85, 0.75])
plot(t, Q_wall, "r-", lw=1, label="Heat extraction rate through borehole wall")
plot(t, Q_surf, "b-", lw=1, label="Downward heat rate through ground surface")
xlabel("Time [a]")
ylabel("Heat rate [W]")
ax.set_xlim([0, 50])
ax.set_ylim([0, 2250])
figlegend(loc="lower center")
ax.grid()

# -------------------------------------------------------------------
# Plots percentages.
# -------------------------------------------------------------------

fig = figure()
ax = axes([0.125, 0.225, 0.85, 0.75])
plot(t_avg, Q_surf_avg*100/Q_wall_avg, "r-", lw=1, label="Heat rates")
plot(t[i], E_surf_cum[i]*100/E_wall_cum[i], "b-", lw=1, label="Cumulative energies")
xlabel("Time [a]")
ylabel("Ground surface to borehole wall ratio [%]")
ax.set_xlim([0, 50])
ax.set_ylim([0, 20])
figlegend(loc="lower center")
ax.grid()

show()
