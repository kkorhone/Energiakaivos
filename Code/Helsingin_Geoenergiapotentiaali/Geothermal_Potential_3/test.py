from pylab import *

data = loadtxt("stream.txt", comments="%")

r = data[:, 0]
z = data[:, 1]
i = data[:, 2]

line_indexes = sorted(unique(i))

for line_index in line_indexes:
    j = where(i == line_index)[0]
    plot(r[j], z[j], "r-")

j = where(i == max(line_indexes))[0]
plot(r[j], z[j], "b-")
plot(r[j[0]], z[j[0]], "bo")
plot(r[j[-1]], z[j[-1]], "bs")

show()
