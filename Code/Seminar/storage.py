from scipy.interpolate import interp1d
from scipy.integrate import trapz
from pylab import *

t, Q = loadtxt("storage_total_heat_rate_2.txt", skiprows=8).T
t, T = loadtxt("storage_outlet_temperature_2.txt", skiprows=8).T

t /= 365.2425 * 86400
Q /= 1000.0

file = open("storage.csv", "w")
file.write(u"Aika [a];L\xe4mp\xf6teho [kW];Kent\xe4st\xe4 tuleva l\xe4mp\xf6tila [\xb0C];Kentt\xe4\xe4n menev\xe4 l\xe4mp\xf6tila\n")
for i in range(len(t)):
    a = int(t[i])
    b = t[i] - a
    if b <= 0.5:
        file.write("%.9f;%.3f;%.3f;40\n" % (t[i], Q[i], T[i]))
    else:
        file.write("%.9f;%.3f;%.3f;2\n" % (t[i], Q[i], T[i]))
file.close()
raise SystemExit
Q1 = -clip(Q, -inf, 0)
Q2 = clip(Q, 0, inf)

E_balance = trapz(Q*1e-6, t*365.2425*24)
E_injected = trapz(Q1*1e-6, t*365.2425*24)
E_extracted = trapz(Q2*1e-6, t*365.2425*24)

print("injected = %.0f GWh" % E_injected)
print("extracted = %.0f GWh" % E_extracted)
print("balance = %+.0f (%+.0f)" % (E_extracted-E_injected, E_balance))

f = interp1d(t, Q)
g = interp1d(t, T)

t = linspace(0, 25, 25*12+1)
Q = f(t)
T = g(t)

t_in = []
Q_in = []

T_in = []
E_in = []

t_out = []
Q_out = []

T_out = []
E_out = []

figure(1, figsize=(11, 5))
figure(2, figsize=(11, 5))

for year in arange(0, 25):
    i = where((year<=t)&(t<=(year+0.5)))[0]
    j = where(((year+0.5)<=t)&(t<=(year+1)))[0]
    T_in.append(mean(t[i]))
    E_in.append(-trapz(Q[i]*1e-6, t[i]*365.2425*24))
    T_out.append(mean(t[j]))
    E_out.append(trapz(Q[j]*1e-6, t[j]*365.2425*24))
    figure(1)
    plot(t[i], Q[i], "r-")
    plot(t[j], Q[j], "b-")
    figure(2)
    plot(t[i], T[i], "r-")
    plot(t[j], T[j], "b-")
    #i, j = i[1:], j[1:]
    #plot(t[i], Q[i], "r.-")
    #plot(t[j], Q[j], "b.-")
    t_in.append(mean(t[i]))
    Q_in.append(-mean(Q[i]))
    t_out.append(mean(t[j]))
    Q_out.append(mean(Q[j]))

print("injected = %.0f GWh, extracted = %.0f GWh" % (sum(E_in), sum(E_out)))

figure(1)
gca().set_xlim([0, 25])
legend(("Injection", "Extraction"), loc="upper center", ncol=2)
xlabel("Time [a]")
ylabel("Heat rate [kW]")
tight_layout()
#savefig("storage_total_heat_rate.png")
raise SystemExit

figure(2)
gca().set_xlim([0, 25])
legend(("Injection", "Extraction"), loc="upper center", ncol=2)
xlabel("Time [a]")
ylabel(u"Outlet temperature [\xb0C]")
tight_layout()
savefig("storage_outlet_temperature.png")

figure(3)
plot(T_in, E_in, "ro-", label="Injected")
plot(T_out, E_out, "bo-", label="Extracted")
title("Thermal energy injected and extracted annually")
xlabel("Time [a]")
ylabel("Thermal energy [GWh/a]")
gca().set_xlim([0, 25])
#gca().set_ylim([800, 2800])
#gca().set_yticks(arange(800, 3000, 200))
legend()
tight_layout()
savefig("storage_annual_average_thermal_energy.png")

figure(4)
plot(t_in, Q_in, "ro-", label="Injected")
plot(t_out, Q_out, "bo-", label="Extracted")
title("Average annual heat rates injected and extracted")
xlabel("Time [a]")
ylabel("Heat rate [kW]")
gca().set_xlim([0, 25])
#gca().set_ylim([800, 2800])
#gca().set_yticks(arange(800, 3000, 200))
legend()
tight_layout()
savefig("storage_average_heat_rate.png")

show()
