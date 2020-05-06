from scipy.interpolate import interp1d
from scipy.integrate import trapz
from pylab import *

def plot_plot(num_bhes):

    print(70*"-")
    print("num_bhes", num_bhes)

    data = loadtxt("ico_field_%d_300m_results.txt" % num_bhes)

    dQ = data[-1,1] - data[-1,2] - data[-1,3]

    print("dQ", dQ)

    Q_total = interp1d(data[:,0], data[:,1]-dQ)
    Q_outside = interp1d(data[:,0], data[:,2]+data[:,3])
    T_field = interp1d(data[:,0], data[:,4])
    T_outlet = interp1d(data[:,0], data[:,5])

    print("T(0)", T_field(0), "T(1e6)", T_field(1e6))

    t = 10**linspace(-6, 6, 1000)

    #plot(t, T_field(t)); show(); raise SystemExit

    V_field = 0.5 * 4.0 / 3.0 * pi * 350**3
    V_ring = pi * 350**2 * 20
    V_total = V_field + V_ring

    # V_total = 4 * 2.4265E7 # COMSOL

    E_content = 2749 * 682 * V_total * (T_field(0) - T_field(1e6)) / (3600 * 1e9)

    E_total = trapz(Q_total(t)*1e-9, t*365.2425*24)
    E_outside = trapz(Q_outside(t)*1e-9, t*365.2425*24)

    print("E_total",E_total/1000,"TWh")
    print("E_total-E_outside",E_total-E_outside)
    print("E_outside",E_outside)
    print("E_content",E_content)

    #figure()

    h1 = fill_between(t, Q_total(t)/1000, Q_outside(t)/1000, color=[1,0.75,0.75])
    h2 = fill_between(t, Q_outside(t)/1000, color=[0.75,0.75,1])

    h3, = semilogx(t, Q_outside(t)/1000, "b-", lw=3)
    h4, = semilogx(t, Q_total(t)/1000, "r-", lw=3)

    h5, = semilogx(1e6, Q_outside(1e6)/1000, "ro", mfc="w", mew=2)

    #text(1e-2, 300, "%.0f GWh"%E_content, ha="center", va="center", fontweight="bold")
    #text(1e+4, 35, "%.0f TWh"%(E_outside/1000), ha="center", va="center", fontweight="bold")
    #text(1e+6, Q_outside(1e6)/1000, "  %.0f kW"%(Q_outside(1e6)/1000), ha="left", va="center")

    setp(h5, "clip_on", False, "zorder", 100)

    gca().set_xlim([1e-3, 1e6])
    gca().set_xticks(10.0**arange(-3, 7, 1))

    #gca().set_ylim([0, 350])
    #ylim = gca().get_ylim()
    #yticks = gca().get_yticks()
    #dy = yticks[1] - yticks[0]
    #print("ylim", ylim)
    #print("yticks", yticks)
    #print("dy", dy)
    #ylim = [0, ceil(ylim[1]/dy)*dy]
    #print("ylim", ylim)
    #gca().set_ylim(ylim)

    gca().set_ylim([0, 4000])
    gca().set_yticks(arange(0,4500,500))

    grid(ls="--", color="k", lw=0.5)

    #title("Field of %d BHEs" % num_bhes)

    xlabel("Time [a]")
    ylabel("Heating power [kW]")

    legend((h4,h3,h1,h2), ("Total power extracted from ground", "Power extracetd from outside field volume", "Heat extracted from field volume", "Heat extracted outside field volume"))

    tight_layout()

    #show()

    savefig("field_%d_bhes.png" % num_bhes)

    #close()

# 15.778408 10.548944 6.040193 5.046946 3.640368

#plot_plot(8)
#plot_plot(25)
#plot_plot(89)
plot_plot(136)
#plot_plot(337)
show()
