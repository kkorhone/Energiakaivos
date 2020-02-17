from pylab import *
from glob import glob

ico = ["quarter_ico_25_bhes_total_heat_rate.txt", "quarter_ico_89_bhes_total_heat_rate.txt", "quarter_ico_136_bhes_total_heat_rate.txt"]
uv = ["quarter_uv_25_bhes_total_heat_rate.txt", "quarter_uv_85_bhes_total_heat_rate.txt", "quarter_uv_145_bhes_total_heat_rate.txt"]

for i in range(3):
    t1, Q1 = loadtxt(ico[i], skiprows=8).T
    t2, Q2 = data2 = loadtxt(uv[i], skiprows=8).T
    plot(t1, Q1, t2, Q2)

#show()
