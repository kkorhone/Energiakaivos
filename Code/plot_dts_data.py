from pylab import *
import pandas

data_frame = pandas.read_excel("dts_data.xlsx", sheet_name="PH-101")

T1, z1 = data_frame["T"].values, data_frame["z"].values

data_frame = pandas.read_excel("dts_data.xlsx", sheet_name="R-2234")

T2, z2 = data_frame["T"].values, data_frame["z"].values

data_frame = pandas.read_excel("dts_data.xlsx", sheet_name="R-2243")

T3, z3 = data_frame["T"].values, data_frame["z"].values

data_frame = pandas.read_excel("dts_data.xlsx", sheet_name="R-2245")

T4, z4 = data_frame["T"].values, data_frame["z"].values

figure(figsize=figaspect(4/3))

plot(T3, -z3, "r.", ms=3)
plot(T1, -z1, "g.", ms=3)
plot(T2, -z2, "b.", ms=3)
plot(T4, -z4, "y.", ms=3)

#z = linspace(0, 2150, 10)

#plot(3+0.038/2.92*z, -z)

xlabel(u"Temperature [\xb0]")
ylabel("Depth [m]")

tight_layout()

savefig("dts_data.png")

show()
