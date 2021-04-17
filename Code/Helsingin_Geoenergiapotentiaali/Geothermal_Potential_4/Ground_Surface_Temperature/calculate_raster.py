import arcpy

arcpy.CheckOutExtension("Spatial")

r = arcpy.Raster(r"E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Potential_4\Ground_Surface_Temperature\T_normal_31-60.tif")

s = 0.71 * r + 2.93

s.save(r"E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Potential_4\Ground_Surface_Temperature\T_ground.tif")
