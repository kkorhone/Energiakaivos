from scipy.io import loadmat
from pylab import *

# ----------------------------------------------------------------------
# Fetches data.
# ----------------------------------------------------------------------

data1 = loadmat("temp1.mat")
#data2 = loadmat("temp2.mat")

borehole_spacing1 = ravel(data1["borehole_spacing"])
borehole_spacing2 = ravel(data2["borehole_spacing"])

i1 = [0, 1, 2, 3, 4, 5, 6, 7, 9]
i2 = [0, 1]

#print borehole_spacing1[i1]
#print borehole_spacing2[i2]

borehole_spacing = hstack((borehole_spacing1[i1], borehole_spacing2[i2]))

#borehole_spacing = array([10, 20, 30, 40, 50, 60, 70, 80, 100])
#borehole_spacing = [120, 140]

x0 = ravel(data1["x0"])
y0 = ravel(data1["y0"])

X0 = ravel(data1["X0"])
Y0 = ravel(data1["Y0"])

x1 = hstack((data1["x1"][:, i1], data2["x1"][:, i2]))
y1 = hstack((data1["y1"][:, i1], data2["y1"][:, i2]))

X1 = hstack((data1["X1"][:, i1], data2["X1"][:, i2]))
Y1 = hstack((data1["Y1"][:, i1], data2["Y1"][:, i2]))

print x1.shape

#raise SystemExit, borehole_spacing

# ----------------------------------------------------------------------
# Plots annual energies.
# ----------------------------------------------------------------------

#params = {"legend.fontsize": 9, "legend.labelspacing": 0.3, "legend.columnspacing": 1.0}
params = {"legend.labelspacing": 0.2, "legend.columnspacing": 0.7, "legend.handletextpad": 0.2}

rcParams.update(params)

colors = ["r", "g", "b", "c", "m", "y"]
styles = ["-", "-", "-", "-", "-", "-", "--", "--", "--", "--", "--", "--", "-.", "-.", "-.", "-.", "-.", "-.", ":", ":", ":", ":", ":", ":"]
widths = hstack((2*ones(len(styles)), 0.5*ones(len(styles))))

#k = [0, 1, 2, 3, 4, 6, 8, 10, 12, 14, 15, 16, 17, 18, 19, 20]
k = range(x1.shape[1]-1)
k = range(len(borehole_spacing))

figure(figsize=(11, 5))

ax1 = subplot2grid((1, 2), (0, 0))
ax2 = subplot2grid((1, 2), (0, 1))

axes(ax1)

counter = 0

for i in k:
    color = colors[counter%len(colors)]
    style = styles[counter%len(styles)]
    width = widths[counter%len(widths)]
    plot(x1[:,i], y1[:,i], ls=style, color=color, lw=width, label="%.0f m"%borehole_spacing[i])
    counter += 1

plot(x0, y0, "k-", lw=3, label="1 kaivo")

legend(ncol=3)

gca().set_xlim([0, 25])
gca().set_ylim([550, 900])

gca().set_xticks(arange(0, 30, 5))
gca().set_yticks(arange(550, 950, 50))

xlabel("Aika [v]")
ylabel(u"Energiakaivosta saatava vuotuinen energiam\xe4\xe4r\xe4 [MWh/v]")

grid(ls="--", lw=0.25, color="k", which="both")

axes(ax2)

counter = 0

for i in k:
    color = colors[counter%len(colors)]
    style = styles[counter%len(styles)]
    width = widths[counter%len(widths)]
    plot(x1[:,i], y1[:,i], ls=style, color=color, lw=width, label="%.0f m"%borehole_spacing[i])
    counter += 1

plot(x0, y0, "k-", lw=3, label="1 kaivo")

gca().set_xlim([0, 1000])
gca().set_ylim([450, 750])

gca().set_xticks(arange(0, 1100, 100))
gca().set_yticks(arange(450, 800, 50))

xlabel("Aika [v]")
#ylabel(u"Energiakaivosta saatava vuotuinen energiam\xe4\xe4r\xe4 [MWh/v]")

grid(ls="--", lw=0.25, color="k", which="both")

tight_layout()

#show(); raise SystemExit
#close()

# ----------------------------------------------------------------------
# Plots cumulative energies.
# ----------------------------------------------------------------------

#3200100 = 7
# 200100 = 6
#  20100 = 5
#   2100 = 4
#    100 = 3
#     10 = 2
#      1 = 1

def thousands(x, pos):
    s = "%.0f" % x
    if len(s) > 7:
        raise ValueError, x
    elif len(s) == 7:
        return s[0]+" "+s[1:4]+" "+s[4:7]
    elif len(s) == 6:
        return s[0:3]+" "+s[3:6]
    elif len(s) == 5:
        return s[0:2]+" "+s[2:5]
    elif len(s) == 4:
        return s[0]+" "+s[1:4]
    elif len(s) == 3:
        return s[0:3]
    elif len(s) == 2:
        return s[0:2]
    elif len(s) == 1:
        return s[0:1]
    else:
        raise ValueError, x

#print thousands(3200100, None)
#print thousands( 200100, None)
#print thousands(  20100, None)
#print thousands(   2100, None)
#print thousands(    100, None)
#print thousands(     10, None)
#print thousands(      1, None)

formatter = FuncFormatter(thousands)

figure(figsize=(11, 5))

ax1 = subplot2grid((1, 2), (0, 0))
ax2 = subplot2grid((1, 2), (0, 1))

ax1.yaxis.set_major_formatter(formatter) 
ax2.yaxis.set_major_formatter(formatter) 

axes(ax1)

counter = 0

for i in k:
    color = colors[counter%len(colors)]
    style = styles[counter%len(styles)]
    width = widths[counter%len(widths)]
    plot(X1[:,i], Y1[:,i], ls=style, color=color, lw=width, label="%.0f m"%borehole_spacing[i])
    counter += 1

plot(X0, Y0, "k-", lw=3, label="1 kaivo")

legend(ncol=3)

gca().set_xlim([0, 25])
gca().set_ylim([0, 22500])

gca().set_xticks(arange(0, 30, 5))
gca().set_yticks(arange(0, 25000, 2500))

xlabel("Aika [v]")
ylabel(u"Energiakaivosta saatava kumulatiivinen energiam\xe4\xe4r\xe4 [MWh]")

grid(ls="--", lw=0.25, color="k", which="both")

axes(ax2)

counter = 0

for i in k:
    color = colors[counter%len(colors)]
    style = styles[counter%len(styles)]
    width = widths[counter%len(widths)]
    plot(X1[:,i], Y1[:,i], ls=style, color=color, lw=width, label="%.0f m"%borehole_spacing[i])
    counter += 1

plot(X0, Y0, "k-", lw=3, label="1 kaivo")

gca().set_xlim([0, 1000])
gca().set_ylim([0, 700000])

gca().set_xticks(arange(0, 1100, 100))
gca().set_yticks(arange(0, 800000, 100000))

xlabel("Aika [v]")
#ylabel(u"Energiakaivosta saatava kumulatiivinen energiam\xe4\xe4r\xe4 [MWh]")

grid(ls="--", lw=0.25, color="k", which="both")

tight_layout()

#show(); raise SystemExit
#close()

# ----------------------------------------------------------------------
# Plots influences.
# ----------------------------------------------------------------------

figure(figsize=(8, 8))

ax1 = subplot2grid((2, 1), (0, 0))
ax2 = subplot2grid((2, 1), (1, 0))

axes(ax1)

counter = 0

for i in k:
    color = colors[counter%len(colors)]
    style = styles[counter%len(styles)]
    width = widths[counter%len(widths)]
    semilogx(x1[:,i], 100*(y1[:,i]-y0)/y0, ls=style, color=color, lw=width, label="%.0f m"%borehole_spacing[i])
    counter += 1

gca().set_xlim([1, 1000])
gca().set_ylim([-30, 0])

gca().set_xticks([1, 10, 25, 50, 100, 1000])
gca().set_yticks(arange(0, -35, -5))

gca().set_xticklabels(["1", "10", "25", "50", "100", "1000"])

axvline(10, ls="--", color="k")
axvline(25, ls="--", color="k")
axvline(50, ls="--", color="k")
axvline(100, ls="--", color="k")

#xlabel("Aika [v]")
ylabel(u"Toisen kaivon vaikutus\nvuotuiseen energiansaantiin [%]")

grid(ls="--", lw=0.25, color="k", which="both")

axes(ax2)

counter = 0

for i in k:
    color = colors[counter%len(colors)]
    style = styles[counter%len(styles)]
    width = widths[counter%len(widths)]
    semilogx(X1[:,i], 100*(Y1[:,i]-Y0)/Y0, ls=style, color=color, lw=width, label="%.0f m"%borehole_spacing[i])
    counter += 1

gca().set_xlim([1, 1000])
gca().set_ylim([-30, 0])

gca().set_xticks([1, 10, 25, 50, 100, 1000])
gca().set_yticks(arange(0, -35, -5))

gca().set_xticklabels(["1", "10", "25", "50", "100", "1000"])

axvline(10, ls="--", color="k")
axvline(25, ls="--", color="k")
axvline(50, ls="--", color="k")
axvline(100, ls="--", color="k")

xlabel("Aika [v]")
ylabel(u"Toisen kaivon vaikutus\nkumulatiiviseen energiansaantiin [%]")

grid(ls="--", lw=0.25, color="k", which="both")

legend(loc=3, ncol=2)

tight_layout()

show()
