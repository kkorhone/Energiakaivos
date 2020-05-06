from scipy.integrate import trapz
from scipy.optimize import leastsq
from pylab import *
import pandas

rho = 2749
Cp = 682
k = 2.92

base_names = ["ico_field_8_300m", "ico_field_25_300m", "ico_field_89_300m", "ico_field_136_300m", "ico_field_337_300m"]

num_bhes = array([8, 25, 89, 136, 337])

V_fields = array([97164279.3013841, 97313615.7888551, 97424926.0351896, 97444574.2027733, 97466575.2320838])

# t Q_total Q_above Q_below T_field T_outlet

colors = ["r", "g", "b", "c", "m", "y", "k"]

E_total = []
E_inside = []
E_outside = []
E_content = []

ymin_ymax_dy = [
(0, 0.25, 0.05),
(0, 0.7, 0.1),
(0, 2.5, 0.5),
(0, 4, 0.5),
(0, 10, 1)
]

for i in range(len(base_names)):

    sheet_name = "%s_solved.mph" % base_names[i]
    data_frame = pandas.read_excel("results.xlsx", sheet_name=sheet_name)

    t = data_frame["t"].values

    Q_total = data_frame["Q_total"].values
    Q_above = data_frame["Q_above"].values
    Q_below = data_frame["Q_below"].values

    T_field = data_frame["T_field"].values
    T_outlet = data_frame["T_outlet"].values

    j = where(t >= 1.0/365)[0]

    figure()

    semilogx(t[j], 1e-6*Q_total[j], "-", color=colors[i])
    #semilogx(t[j], 1e-6*(Q_above[j]+Q_below[j]), "--", color=colors[i])

    minorticks_off()

    #ylim = gca().get_ylim()

    ymin, ymax, dy = ymin_ymax_dy[i]

    gca().set_ylim([ymin, ymax])
    gca().set_yticks(arange(ymin, ymax+dy, dy))
    gca().set_xlim([1.0/365, 100])
    gca().set_xticks([1.0/365, 1.0/12, 1.0, 10, 100])
    gca().set_xticklabels(["1 day", "1 month", "1 year", "10 years", "100 years"])

    title("%d BHEs" % num_bhes[i])

    xlabel("Time")
    ylabel("Heating power [MW]")

    savefig("test_%d.png" % i)
    close()

    E_total.append(trapz(Q_total*1e-9, t*365.2425*24))
    E_inside.append(trapz((Q_total-Q_above-Q_below)*1e-9, t*365.2425*24))
    E_outside.append(trapz((Q_above+Q_below)*1e-9, t*365.2425*24))
    #E_content.append(rho*Cp*V_fields[i]*(T_field[0]-T_field[-1])/(3600*1e9))
    E_content.append(rho*Cp*V_fields[i]*(T_field[0]-2.0)/(3600*1e9))

fun = lambda n,p: p[0]*log10(p[1]*n+p[2])+p[3]
err = lambda p: fun(num_bhes,p) - E_total

p = [500, 1, 1, 1]
p = leastsq(err, p)[0]

print("params=%s"%p)
print("residuals=%s"%err(p))

figure()

n = linspace(1, 350, 10000)

plot(n, fun(n,p), "r-", lw=2)
plot(num_bhes, E_total, "o", label="Total from field", mec="r", mfc="w", mew=2)
#plot(num_bhes, E_inside, "go-", label="From field volume")
#plot(num_bhes, E_outside, "bo-", label="Outside field volume")
#plot(num_bhes, E_content, "co-", label="content")

xlabel("Number of BHEs")
ylabel("Thermal energy extracted [GWh]")

title("Thermal energy extracted from\na hemispherical BHE field\nwith a radius of 300 m")

#legend()

savefig("test.png")

show()
