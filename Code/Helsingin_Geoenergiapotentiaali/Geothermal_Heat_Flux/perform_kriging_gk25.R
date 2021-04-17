# setwd("E:\\Work\\Helsingin_Geoenergiapotentiaali\\Geothermal_Heat_Flux")
# source("perform_kriging_gk25.R")

library(spatial)
library(raster)
library(gstat)
library(rgdal)
library(sp)

heat_flow_map = read.table("heat_flow_map_gk25.txt")

x = heat_flow_map$V1
y = heat_flow_map$V2
Q = heat_flow_map$V4


hf.data = data.frame(cbind(x, y, Q))

names(hf.data) = cbind("x", "y", "Q")
coordinates(hf.data) = ~x + y

bins = seq(0, 700000, by=5000)

vg = variogram(Q~1, data=hf.data, boundaries=bins)
#vm = fit.variogram(vg, vgm(psill=0.6, nugget=0.2, range=350000, model="Exp"))
#vm = vgm(psill=0.6, nugget=0.2, range=350000, model="Mat")
vm = vgm(psill=65, nugget=25, range=375000, model="Exp")

plot(vg, model=vm)

xi = seq(25201220.61, 25827220.61, length.out=313)
yi = seq(6650767.223, 7770767.223, length.out=560)

grd = expand.grid(x=xi, y=yi)

coordinates(grd) = ~x + y
gridded(grd) = TRUE

gst = gstat(id="Q", formula=Q~1, data=hf.data, model=vm)

pred.Q = predict(gst, newdata=grd)
rast.Q = raster(pred.Q)

writeRaster(rast.Q, "geothermal_heat_flux_finland_gk25.tif", format="GTiff")
