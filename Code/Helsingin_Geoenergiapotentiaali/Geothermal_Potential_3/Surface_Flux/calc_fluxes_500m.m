clc

cd E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Potential_3
model = init_150m_model(500);
model.param.set('annual_energy_demand', sprintf('%.30f[MW*h]', 4.883));
model.sol('sol1').runAll();

cd E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Potential_3\Surface_Flux
write_results(model, 'fluxes_150m_500m.txt');

cd E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Potential_3
model = init_300m_model(500);
model.param.set('annual_energy_demand', sprintf('%.30f[MW*h]', 9.125));
model.sol('sol1').runAll();

cd E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Potential_3\Surface_Flux
write_results(model, 'fluxes_300m_500m.txt');

cd E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Potential_3
model = init_1000m_model(500);
model.param.set('annual_energy_demand', sprintf('%.30f[MW*h]', 30.482));
model.sol('sol1').runAll();

cd E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Potential_3\Surface_Flux
write_results(model, 'fluxes_1000m_500m.txt');
