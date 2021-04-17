import pandas

data_frame1 = pandas.read_excel("map_points_intersect_gk25.xlsx")
data_frame2 = pandas.read_excel("surface_temperature_gk25.xlsx")
data_frame3 = pandas.read_excel("geothermal_heat_flux_gk25.xlsx")

x, y, k, Cp, rho, T, q = [], [], [], [], [], [], []

skipped = 0

for i, row in data_frame1.iterrows():
    df1 = data_frame2[(abs(data_frame2["POINT_X"]-row["POINT_X"])<0.001)&(abs(data_frame2["POINT_Y"]-row["POINT_Y"])<0.001)]
    df2 = data_frame3[(abs(data_frame3["POINT_X"]-row["POINT_X"])<0.001)&(abs(data_frame3["POINT_Y"]-row["POINT_Y"])<0.001)]
    if len(df1) == 0 or len(df2) == 0:
        skipped += 1
    elif len(df1) == 1 and len(df2) == 1:
        x.append(row["POINT_X"])
        y.append(row["POINT_Y"])
        k.append(row["Therm_Cond"])
        Cp.append(row["Spec_Heat"])
        rho.append(row["Density"])
        T.append(df1["GRID_CODE"])
        q.append(df2["GRID_CODE"])
    else:
        raise ValueError
    if i % 1000 == 0:
        print float(i * 100) / len(data_frame1)

print "skipped=%d" % skipped
print "len(q)=%d" % len(q)
print "len(data_frame1)=%d" % len(data_frame1)
print "len(data_frame2)=%d" % len(data_frame2)
print "len(data_frame3)=%d" % len(data_frame3)

csv_file = open("sampled_map_points_gk25.csv", "w")

csv_file.write("x,y,k_rock,Cp_rock,rho_rock,T_surface,q_geothermal\n")

for _x, _y, _k, _Cp, _rho, _T, _q in zip(x, y, k, Cp, rho, T, q):
    csv_file.write("%.11f,%.11f,%.11f,%.11f,%.11f,%.11f,%.11f\n" % (_x, _y, _k, _Cp, _rho, _T, _q))

csv_file.close()
