import arcpy
import os

release_path = r"E:\Work\Helsingin_Geoenergiapotentiaali\Tulosaineistot"

source_data = [
    (r"E:\Work\Helsingin_Geoenergiapotentiaali\Bedrock_Map\bedrock_map_gk25.shp", "termogeologiset_parametrit.shp", None),
    (r"E:\Work\Helsingin_Geoenergiapotentiaali\Soil_Thickness\soil_thickness_nulled_gk25.tif", "maapeitteen_paksuus.tif", 10),
    (r"E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Gradient\geothermal_gradient_gk25.tif", "geoterminen_gradientti.tif", 100),
    (r"E:\Work\Helsingin_Geoenergiapotentiaali\Surface_Temperature\surface_temperature_gk25.tif", u"maanpinnan_keskil\xe4mp\xf6tila.tif", 100),
    (r"E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Heat_Flux\geothermal_heat_flux_gk25.tif", u"geoterminen_l\xe4mp\xf6vuo.tif", 100),
]

for file_name in os.listdir(release_path):
    path_name = os.path.join(r"E:\Work\Helsingin_Geoenergiapotentiaali\Tulosaineistot", file_name)
    print "Removing \"%s\"..." % file_name,
    os.remove(path_name)
    print "Done."

for source_path, destination_name, cell_size in source_data:
    print "Copying \"%s\" to \"%s\"..." % (source_path, destination_name),
    destination_path = os.path.join(release_path, destination_name)
    arcpy.Copy_management(source_path, destination_path)
    print "Done."
