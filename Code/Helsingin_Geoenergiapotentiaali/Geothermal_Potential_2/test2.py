from pylab import *

data_20m = loadtxt("bhe_field_5x5_20m.txt", skiprows=8)
data_50m = loadtxt("bhe_field_5x5_50m.txt", skiprows=8)

t_20m, T_20m = data_20m.T
t_50m, T_50m = data_50m.T

plot(t_20m, T_20m, "r-", label="20 m")
plot(t_50m, T_50m-0.04, "b-", label="50 m")

gca().set_xlim([-0.3, 50.3])
gca().set_ylim([0, 9])

xlabel("Aika [a]")
ylabel(u"Kaivon sein\xe4m\xe4m\xe4n keskil\xe4mp\xf6tila [\xb0C]")

legend(loc=1)

tight_layout()

savefig("test.png")

show()
