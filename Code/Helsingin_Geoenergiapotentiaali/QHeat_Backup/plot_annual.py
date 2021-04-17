from pylab import *

borehole_spacing = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 120, 140, 160, 180, 200, 250, 300, 350, 400, 450, 500]

data = loadtxt("results_annual.txt")
#data = loadtxt("results_cumulative.txt")

x0 = data[:, 0]
y0 = data[:, 1]

y1 = zeros((len(x0), len(borehole_spacing)))
y2 = zeros((len(x0), len(borehole_spacing)))

p1 = zeros((len(x0), len(borehole_spacing)))
p2 = zeros((len(x0), len(borehole_spacing)))

for i in range(len(borehole_spacing)):

    y1[:, i] = data[:, i+2]
    y2[:, i] = data[:, i+2+len(borehole_spacing)]

    p1[:, i] = (y1[:, i] - y0) * 100.0 / y0
    p2[:, i] = (y2[:, i] - y0) * 100.0 / y0

#for i in range(len(x0)):
for i in [len(x0)-1]:
    plot(borehole_spacing, p1[i, :], ".-", label="t=%.3f"%x0[i])

legend()

#print x0[23]

#gca().set_xlim([1, 1000])
#gca().set_xlim([0, 25])

show()
