from scipy.integrate import trapz
from pylab import *

# -------------------------------------------------------------------
# Evaluates annual average heat rates.
# -------------------------------------------------------------------

def eval_avg_heat_rates(t, Q_wall, Q_surf):
    t_avg, Q_wall_avg, Q_surf_avg = [], [], []

    for year in range(50):
        i = where(((year-0.001) <= t) & (t <= (year+1.001)))[0]
        t_avg.append(mean(t[i]))
        Q_wall_avg.append(mean(Q_wall[i]))
        Q_surf_avg.append(mean(Q_surf[i]))

    return array(t_avg), array(Q_wall_avg), array(Q_surf_avg)

# -------------------------------------------------------------------
# Evaluates cumulative energies.
# -------------------------------------------------------------------

def eval_cum_energies(t, Q_wall, Q_surf):

    E_wall_cum, E_surf_cum = [], []

    for i in range(len(t)):
        E_wall_cum.append(trapz(Q_wall[:i], t[:i]))
        E_surf_cum.append(trapz(Q_surf[:i], t[:i]))

    return array(E_wall_cum), array(E_surf_cum)

# -------------------------------------------------------------------
# Loads data.
# -------------------------------------------------------------------

colors = ["r", "r", "g", "g", "b", "b"]
styles = ["-", "--", "-", "--", "-", "--"]

i = 0

for borehole_length in [150, 300, 1000]:
    for borehole_spacing in [20, 500]:

        txt_name = "fluxes_%dm_%dm.txt" % (borehole_length, borehole_spacing)

        data = loadtxt(txt_name)

        t = data[:, 0]

        Q_wall = data[:, 1]
        Q_surf = data[:, 2]

        t_avg, Q_wall_avg, Q_surf_avg = eval_avg_heat_rates(t, Q_wall, Q_surf)
        E_wall_cum, E_surf_cum = eval_cum_energies(t, Q_wall, Q_surf)

        j = where(t >= 1)[0]

        if borehole_spacing == 20:
            label = "Field of %d-m boreholes" % borehole_length
        elif borehole_spacing == 500:
            label = "Single borehole of %d-m" % borehole_length
        else:
            raise ValueError, "invalid borehole length: %d" % borehole_length

        figure(1)
        plot(t_avg, Q_surf_avg*100/Q_wall_avg, label=label, ls=styles[i], color=colors[i])

        figure(2)
        plot(t[j], E_surf_cum[j]*100/E_wall_cum[j], label=label, ls=styles[i], color=colors[i])

        i += 1

figure(1)
xlabel("Time [a]")
ylabel("Heat rate ratio [%]")
gca().set_xlim([0, 50])
gca().set_ylim([0, 35])
legend()
grid()
tight_layout()
savefig("heat_rate_ratio.png")

figure(2)
xlabel("Time [a]")
ylabel("Cumulative energy ratio [%]")
gca().set_xlim([0, 50])
gca().set_ylim([0, 25])
legend()
grid()
tight_layout()
savefig("cumulative_energy_ratio.png")

show()
