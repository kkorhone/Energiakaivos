from scipy.optimize import minimize_scalar
from scipy.interpolate import interp1d
from scipy.io import loadmat
from pylab import *

# ----------------------------------------------------------------------
# Fetches data.
# ----------------------------------------------------------------------

data = loadmat("results5.mat")

borehole_spacing = ravel(data["borehole_spacing"])
#borehole_spacing = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]

x0 = ravel(data["x0"])
y0 = ravel(data["y0"])

X0 = ravel(data["X0"])
Y0 = ravel(data["Y0"])

x1 = data["x1"]
y1 = data["y1"]

X1 = data["X1"]
Y1 = data["Y1"]

# ----------------------------------------------------------------------
# Writes 5-percent files for safety distance.
# ----------------------------------------------------------------------

txt_file = open("annual.txt", "w")

for time in arange(5, 200, 5):
    P = []
    for i in range(len(borehole_spacing)):
        t = x1[:, i]
        p = 100*(y1[:, i] - y0) / y0
        lerp = interp1d(t, p)
        P.append(lerp(time))
    lerp = interp1d(ravel(P), borehole_spacing)
    txt_file.write("%3d %.3f\n" % (time, lerp(-5)))

txt_file.close()

txt_file = open("cumulative.txt", "w")

for time in arange(5, 200, 5):
    P = []
    for i in range(len(borehole_spacing)):
        t = X1[:, i]
        p = 100*(Y1[:, i] - Y0) / Y0
        lerp = interp1d(t, p)
        P.append(lerp(time))
    lerp = interp1d(ravel(P), borehole_spacing)
    txt_file.write("%3d %.3f\n" % (time, lerp(-5)))

txt_file.close()

raise SystemExit

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

legend(ncol=2)

gca().set_xlim([0, 25])
gca().set_ylim([650, 1050])

gca().set_xticks(arange(0, 30, 5))
gca().set_yticks(arange(650, 1100, 50))

xlabel("Aika [v]")
ylabel(u"L\xe4mp\xf6kaivosta saatava vuotuinen energiam\xe4\xe4r\xe4 [MWh/v]")

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
gca().set_ylim([500, 900])

gca().set_xticks(arange(0, 1100, 100))
gca().set_yticks(arange(500, 950, 50))

xlabel("Aika [v]")
#ylabel(u"L\xe4mp\xf6kaivosta saatava vuotuinen energiam\xe4\xe4r\xe4 [MWh/v]")

grid(ls="--", lw=0.25, color="k", which="both")

tight_layout()

savefig("vuotuinen.png")

#show(); raise SystemExit
close()

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

legend(ncol=2)

gca().set_xlim([0, 25])
gca().set_ylim([0, 25000])

gca().set_xticks(arange(0, 30, 5))
gca().set_yticks(arange(0, 27500, 2500))

xlabel("Aika [v]")
ylabel(u"L\xe4mp\xf6kaivosta saatava kumulatiivinen energiam\xe4\xe4r\xe4 [MWh]")

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
gca().set_ylim([0, 800000])

gca().set_xticks(arange(0, 1100, 100))
gca().set_yticks(arange(0, 900000, 100000))

xlabel("Aika [v]")
#ylabel(u"L\xe4mp\xf6kaivosta saatava kumulatiivinen energiam\xe4\xe4r\xe4 [MWh]")

grid(ls="--", lw=0.25, color="k", which="both")

tight_layout()

savefig("kumulatiivinen.png")

#show(); raise SystemExit
close()

# ----------------------------------------------------------------------
# Plots influences.
# ----------------------------------------------------------------------

figure(figsize=(8, 8))

ax1 = subplot2grid((2, 1), (0, 0))
ax2 = subplot2grid((2, 1), (1, 0))

axes(ax1)

print 70 * "-"
print "Annual"
print 70 * "-"
print "%20s %10s %10s %10s %10s %10s" % ("borehole_spacing", "10 years", "25 years", "50 years", "100 years", "1000 years")

counter = 0

for i in k:
    color = colors[counter%len(colors)]
    style = styles[counter%len(styles)]
    width = widths[counter%len(widths)]
    lerp = interp1d(x1[:,i], 100*(y1[:,i]-y0)/y0)
    print "%20d %10.1f %10.1f %10.1f %10.1f %10.1f" % (borehole_spacing[i], lerp(10), lerp(25), lerp(50), lerp(100), lerp(999))
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
ylabel(u"Toisen l\xe4mp\xf6kaivon vaikutus\nvuotuiseen energiansaantiin [%]")

grid(ls="--", lw=0.25, color="k", which="both")

axes(ax2)

print 70 * "-"
print "Cumulative"
print 70 * "-"
print "%20s %10s %10s %10s %10s %10s" % ("borehole_spacing", "10 years", "25 years", "50 years", "100 years", "1000 years")

counter = 0

for i in k:
    color = colors[counter%len(colors)]
    style = styles[counter%len(styles)]
    width = widths[counter%len(widths)]
    lerp = interp1d(X1[:,i], 100*(Y1[:,i]-Y0)/Y0)
    print "%20d %10.1f %10.1f %10.1f %10.1f %10.1f" % (borehole_spacing[i], lerp(10), lerp(25), lerp(50), lerp(100), lerp(999))
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
ylabel(u"Toisen l\xe4mp\xf6kaivon vaikutus\nkumulatiiviseen energiansaantiin [%]")

grid(ls="--", lw=0.25, color="k", which="both")

legend(loc=3, ncol=2)

tight_layout()

savefig("prosentit.png")

show()
