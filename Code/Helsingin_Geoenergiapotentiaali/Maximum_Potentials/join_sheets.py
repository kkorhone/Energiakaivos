import pandas

sheet1 = pandas.read_excel("bedrock_map_intersect_gk25.xlsx", sheet_name="bedrock_map_intersect")
sheet2 = pandas.read_excel("bedrock_map_intersect_gk25.xlsx", sheet_name="surface_temperature")
sheet3 = pandas.read_excel("bedrock_map_intersect_gk25.xlsx", sheet_name="geothermal_heat_flux")

x1, y1 = [], []
x2, y2 = [], []
x3, y3 = [], []

feature1 = []
feature2 = []
feature3 = []
feature4 = []
feature5 = []

for i, row in sheet1.iterrows():
    df1 = sheet2[(sheet2["POINT_X"]==row["POINT_X"]) & (sheet2["POINT_Y"]==row["POINT_Y"])]
    df2 = sheet3[(sheet3["POINT_X"]==row["POINT_X"]) & (sheet3["POINT_Y"]==row["POINT_Y"])]
    assert len(df1) == 1
    assert len(df2) == 1
    x1.append(row["POINT_X"])
    y1.append(row["POINT_Y"])
    x2.append(df1["POINT_X"])
    y2.append(df1["POINT_Y"])
    x3.append(df2["POINT_X"])
    y3.append(df2["POINT_Y"])
    feature1.append(row["Therm_Cond"])
    feature2.append(row["Spec_Heat"])
    feature3.append(row["Density"])
    feature4.append(df1["GRID_CODE"])
    feature5.append(df2["GRID_CODE"])
    if i % 1000 == 0:
        print "%.3f" % (i * 100 / len(sheet1))

csv_file = open("sampled_map_points_gk25.csv", "w")

for i in range(len(x1)):
    csv_file.write("%.11f,%.11f,%.11f,%.11f,%.11f," % (x1[i], y1[i], feature1[i], feature2[i], feature3[i]))
    csv_file.write("%.11f,%.11f,%.11f," % (x2[i], y2[i], feature4[i]))
    csv_file.write("%.11f,%.11f,%.11f\n" % (x3[i], y3[i], feature5[i]))

csv_file.close()
