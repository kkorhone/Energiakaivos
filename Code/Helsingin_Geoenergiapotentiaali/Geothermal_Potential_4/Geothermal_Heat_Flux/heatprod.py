import pandas
import pylab
import numpy

data_frame = pandas.read_excel("heatprod.xlsx")

print(data_frame)

x, y, U, A = data_frame[["XEUREF", "YEUREF", "UNIT", "A"]].values.T

print(len(x))

print(numpy.percentile(A, 95))
print(numpy.percentile(A, 97.5))
print(numpy.percentile(A, 99.5))
print(numpy.percentile(A, 99.9))

p = numpy.percentile(A, 99.0)

i = numpy.where(A <= p)[0]

x, y, U, A = x[i], y[i], U[i], A[i]

print(len(x))

pylab.figure()
pylab.hist(A, 100)

pylab.figure()
pylab.scatter(x, y, c=U, s=2, cmap="rainbow")
pylab.axis("equal")

pylab.figure()
pylab.scatter(x, y, c=A, s=2, cmap="rainbow")
pylab.axis("equal")

pylab.show()

csv_file = open("without_outliers.csv", "w")

csv_file.write("x;y;U;A\n")

for i in range(len(x)):
    csv_file.write("%.4f;%.4f;%.0f;%.12f\n" % (x[i], y[i], U[i], A[i]))

csv_file.close()
