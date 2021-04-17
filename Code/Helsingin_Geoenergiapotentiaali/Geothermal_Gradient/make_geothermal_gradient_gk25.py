import pandas

data_frame1 = pandas.read_excel("geothermal_heat_flux_gk25.xlsx")
data_frame2 = pandas.read_excel("sampled_map_points_gk25.xlsx")

x, y, G = [], [], []

skipped = 0

for i, row in data_frame1.iterrows():
    df = data_frame2[(abs(data_frame2["POINT_X"]-row["POINT_X"])<0.001)&(abs(data_frame2["POINT_Y"]-row["POINT_Y"])<0.001)]
    if len(df) == 0:
        skipped += 1
    elif len(df) == 1:
        x.append(row["POINT_X"])
        y.append(row["POINT_Y"])
        G.append(0.1*row["GRID_CODE"]/df["Therm_Cond"])
    else:
        raise ValueError
    if i % 1000 == 0:
        print float(i * 100) / len(data_frame1)

print "skipped=%d" % skipped
print "len(G)=%d" % len(G)
print "len(data_frame1)=%d" % len(data_frame1)
print "len(data_frame2)=%d" % len(data_frame2)

raise SystemExit

csv_file = open("geothermal_gradient_gk25.csv", "w")

csv_file.write("x,y,G\n")

for _x, _y, _G in zip(x, y, G):
    csv_file.write("%.11f,%.11f,%.11f\n" % (_x, _y, _G))

csv_file.close()
