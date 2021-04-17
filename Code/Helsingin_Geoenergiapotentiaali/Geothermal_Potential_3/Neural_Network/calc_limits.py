from pylab import *

data1 = loadtxt("field_polies_300m_20m_min.txt")
data2 = loadtxt("field_polies_1000m_20m_min.txt")
data3 = loadtxt("train_300m_20m_min.txt")
data4 = loadtxt("train_1000m_20m_min.txt")
data5 = loadtxt("test_300m_20m_min.txt")
data6 = loadtxt("test_1000m_20m_min.txt")

data_300 = vstack((data1[:,1:], data3[:,3:], data5[:,3:]))
data_1000 = vstack((data2[:,1:], data4[:,3:], data6[:,3:]))

a = argsort(data_300[:,-1])
b = argsort(data_1000[:,-1])

print min(data_300[:,-3]), min(data_300[:,-2])
print max(data_300[:,-3]), max(data_300[:,-2])

print "min: %.2f %.0f %.0f %.3f %.3f %.3f" % tuple(data_300[a[0],:])
print "max: %.2f %.0f %.0f %.3f %.3f %.3f" % tuple(data_300[a[-1],:])
