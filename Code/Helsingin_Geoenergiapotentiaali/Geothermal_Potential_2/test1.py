from pylab import *

r1 = 140.0
r2 = 160.0
r3 = 200.0

data1 = loadtxt("comsol_average_model_150m.txt")
data2 = loadtxt("comsol_average_model_300m.txt")
data3 = loadtxt("comsol_average_model_1000m.txt")

def plot_general():
    plot(data1[:,0], data1[:,1], "r.-", label="150 m")
    plot(data2[:,0], data2[:,1], "g.-", label="300 m")
    plot(data3[:,0], data3[:,1], "b.-", label="1000 m")
    gca().set_xlim([0, 200])
    gca().set_ylim([0, 220])
    gca().set_xticks(arange(0, 320, 20))
    gca().set_yticks(arange(0, 240, 20))
    legend(loc=4)

def plot_single_well():
    i1 = find(data1[:,0]>=r1)
    i2 = find(data2[:,0]>=r2)
    i3 = find(data3[:,0]>=r3)
    m1 = mean(data1[i1,1])
    m2 = mean(data2[i2,1])
    m3 = mean(data3[i3,1])
    plot(data1[:,0], data1[:,1], "r.-", label="150 m")
    plot(data2[:,0], data2[:,1], "g.-", label="300 m")
    plot(data3[:,0], data3[:,1], "b.-", label="1000 m")
    axhline(m1, ls="--", color="r")
    axhline(m2, ls="--", color="g")
    axhline(m3, ls="--", color="b")
    gca().set_xlim([0, 300])
    gca().set_ylim([0, 220])
    gca().set_xticks(arange(0, 320, 20))
    gca().set_yticks(arange(0, 240, 20))
    print "%.3f %.3f %.3f" % (m1, m2, m3)

def plot_20_metres():
    plot(data1[:,0], data1[:,1], "ro-", label="150 m")
    plot(data2[:,0], data2[:,1], "go-", label="300 m")
    plot(data3[:,0], data3[:,1], "bo-", label="1000 m")
    plot([0.000, 19.667, 19.667], [6.094, 6.094, 0.000], "r--")
    plot([0.000, 20.000, 20.000], [11.354, 11.354, 0.000], "g--")
    plot([0.000, 20.333, 20.333], [51.578, 51.578, 0.000], "b--")
    gca().set_xlim([0, 60])
    gca().set_ylim([0, 60])
    gca().set_xticks(arange(0, 70, 10))
    gca().set_yticks(arange(0, 65, 5))
    print "%.3f %.3f %.3f" % (6.094, 11.354, 51.578)

def plot_well_radius():
    i1 = find(data1[:,0]>=r1)
    i2 = find(data2[:,0]>=r2)
    i3 = find(data3[:,0]>=r3)
    j1 = find(data1[:,0]<=r1)
    j2 = find(data2[:,0]<=r2)
    j3 = find(data3[:,0]<=r3)
    m1 = mean(data1[i1,1])
    m2 = mean(data2[i2,1])
    m3 = mean(data3[i3,1])
    plot([r1, r1, 300], [0, m1, m1], "r--")
    plot([r2, r2, 300], [0, m2, m2], "g--")
    plot([r3, r3, 300], [0, m3, m3], "b--")
    plot(data1[i1,0], data1[i1,1], "r.", label="150 m")
    plot(data2[i2,0], data2[i2,1], "g.", label="300 m")
    plot(data3[i3,0], data3[i3,1], "b.", label="1000 m")
    plot(data1[j1,0], data1[j1,1], "r.-", label="150 m")
    plot(data2[j2,0], data2[j2,1], "g.-", label="300 m")
    plot(data3[j3,0], data3[j3,1], "b.-", label="1000 m")
    gca().set_xlim([0, 300])
    gca().set_ylim([0, 220])
    gca().set_xticks(arange(0, 320, 20))
    gca().set_yticks(arange(0, 240, 20))
    print "%.3f %.3f %.3f" % (r1, r2, r3)

#plot_general()
#plot_single_well()
#plot_20_metres()
plot_well_radius()

xlabel(u"Kaivojen v\xe4limatka [m]")
ylabel(u"Saatava energiam\xe4\xe4r\xe4 [MWh/a]")

tight_layout()

savefig("test.png")

show()