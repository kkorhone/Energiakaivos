from scipy.interpolate import interp1d
from pylab import *

borehole_spacing = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 120, 140, 160, 180, 200, 250, 300, 350, 400, 450, 500]

data = loadtxt("results_cumulative.txt")

x0 = data[:, 0]
y0 = data[:, 1]

y1 = zeros((len(x0), len(borehole_spacing)))
y2 = zeros((len(x0), len(borehole_spacing)))

dy1 = zeros((len(x0), len(borehole_spacing)))
dy2 = zeros((len(x0), len(borehole_spacing)))

for i in range(len(borehole_spacing)):

    y1[:, i] = data[:, i+2]
    y2[:, i] = data[:, i+2+len(borehole_spacing)]

    dy1[:, i] = y1[:, i] - y0
    dy2[:, i] = y2[:, i] - y0

plot(x0, dy1)

gca().set_xlim([0, 25])
gca().set_ylim([0, -3000])

show()
