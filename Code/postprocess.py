from scipy.integrate import trapz, cumtrapz
from scipy.interpolate import interp1d
from pylab import *

# Sets up parameters.

num_boreholes = 1 + 9 * 24

T_inlet = 30.0

rho_fluid = 1000.0
Cp_fluid = 4186.0
Q_fluid = 0.6 / 1000

rho_rock = 2700.0
Cp_rock = 750.0

r_field = 320.0

V_field = 0.5 * 4.0 / 3.0 * pi * r_field**3

# Loads data.

t, Q_walls = loadtxt("total_heat_rate.txt", skiprows=8).T
t, T_field = loadtxt("average_field_temperature.txt", skiprows=8).T
t, T_outlet = loadtxt("field_outlet_temperature.txt", skiprows=8).T
t, Q_loss = loadtxt("heat_loss_from_field.txt", skiprows=8).T

# Calculates the heat lost from the heat carrier fluid.

Q_outlet = rho_fluid * Cp_fluid * (num_boreholes * Q_fluid) * (T_outlet - T_inlet)

# Calculates heat gained by the rock volume of the BHE field.

E_volume = rho_rock * Cp_rock * V_field * (T_field - T_field[0]) / 3600

# Calculates the energy injected each year.

lerp = interp1d(t, Q_walls)

t_annual = arange(100) + 0.5
E_annual = zeros(len(t_annual))

for i in range(100):
    ti = linspace(i, i+1, 100000)
    Qi = lerp(ti)
    E_annual[i] = trapz(Qi, ti*365.2425*24)

# Calculates the cumulative energy injected.

E_cumul = hstack((0, cumtrapz(Q_walls, t*365.2425*24)))
E_lost = hstack((0, cumtrapz(Q_loss, t*365.2425*24)))

# Plots the results.

figure()

h1, = semilogx(t, Q_outlet*1e-6, "r-", label="Heat lost from the fluid")
h2, = semilogx(t, Q_walls*1e-6, "b.", label="Heat lost through borehole walls")

gca().set_xticks(logspace(-8, 2, 11))
gca().set_yticks(arange(0, -14, -1))

gca().set_xlim([10**-8, 10**2])
gca().set_ylim([0, -13])

grid(ls="--", lw=0.25, color="k")

xlabel("Time [a]")
ylabel("Heat injection rate [MW]")

legend()

tight_layout()

savefig("heat_injection_rate.png")

figure()

step(t_annual, E_annual*1e-9, "r-")

gca().set_xticks(arange(0, 110, 10))
gca().set_yticks(arange(0, -40, -5))

gca().set_xlim([0, 100])
gca().set_ylim([0, -35])

xlabel("Time [a]")
ylabel("Annually injected thermal energy [GWh/a]")

grid(ls="--", lw=0.25, color="k")

tight_layout()

savefig("annually_injected_thermal_energy.png")

figure()

plot(t, E_cumul*1e-9, "b-", label="Injected through borehole walls")
plot(t, -E_volume*1e-9, "r-", label="Gained by field volume")
plot(t, (E_cumul+E_volume)*1e-9, "g-", label="Lost from field volume")

gca().set_xticks(arange(0, 110, 10))
gca().set_yticks(arange(0, -1100, -100))

gca().set_xlim([0, 100])
gca().set_ylim([0, -1000])

xlabel("Time [a]")
ylabel("Cumulative thermal energy [GWh]")

legend()

grid(ls="--", lw=0.25, color="k")

tight_layout()

savefig("cumulative_thermal_energy.png")

figure()

plot(t, T_field, "r-")

gca().set_xticks(arange(0, 110, 10))

gca().set_xlim([0, 100])
gca().set_ylim([8, 26])

xlabel("Time [a]")
ylabel("Average temperature of field volume [degC]")

grid(ls="--", lw=0.25, color="k")

tight_layout()

savefig("average_field_temperature.png")

figure()

plot(t, T_outlet, "r-")

gca().set_xticks(arange(0, 110, 10))

gca().set_xlim([0, 100])
gca().set_ylim([22, 30])

xlabel("Time [a]")
ylabel("Outlet temperature from field [degC]")

grid(ls="--", lw=0.25, color="k")

tight_layout()

savefig("field_outlet_temperature.png")

savetxt("annual_thermal_energy.txt", vstack((t_annual, E_annual)).T)
savetxt("cumulative_thermal_energy.txt", vstack((t, E_cumul)).T)

show()
