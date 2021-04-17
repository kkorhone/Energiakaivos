cd E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Potential_3

model = init_150m_model(20);
E_150m_20m = find_annual_energy_demand(model);

model = init_150m_model(500);
E_150m_500m = find_annual_energy_demand(model);

model = init_300m_model(20);
E_300m_20m = find_annual_energy_demand(model);

model = init_300m_model(500);
E_300m_500m = find_annual_energy_demand(model);

model = init_1000m_model(20);
E_1000m_20m = find_annual_energy_demand(model);

model = init_1000m_model(500);
E_1000m_500m = find_annual_energy_demand(model);

cd E:\Work\Helsingin_Geoenergiapotentiaali\Geothermal_Potential_3\Cooling_Included

model = init_150m_model(20);
E_150m_20m_cooling = find_annual_energy_demand(model);

model = init_150m_model(500);
E_150m_500m_cooling = find_annual_energy_demand(model);

model = init_300m_model(20);
E_300m_20m_cooling = find_annual_energy_demand(model);

model = init_300m_model(500);
E_300m_500m_cooling = find_annual_energy_demand(model);

model = init_1000m_model(20);
E_1000m_20m_cooling = find_annual_energy_demand(model);

model = init_1000m_model(500);
E_1000m_500m_cooling = find_annual_energy_demand(model);

fprintf(1, '----------------------------------------------------------\n');
fprintf(1, 'Summary of results\n');
fprintf(1, '----------------------------------------------------------\n');
fprintf(1, 'E_150m_20m           = %.3f\n', E_150m_20m);
fprintf(1, 'E_150m_20m_cooling   = %.3f\n', E_150m_20m_cooling);
fprintf(1, 'E_150m_500m          = %.3f\n', E_150m_500m);
fprintf(1, 'E_150m_500m_cooling  = %.3f\n', E_150m_500m_cooling);
fprintf(1, '----------------------------------------------------------\n');
fprintf(1, 'E_300m_20m           = %.3f\n', E_300m_20m);
fprintf(1, 'E_300m_20m_cooling   = %.3f\n', E_300m_20m_cooling);
fprintf(1, 'E_300m_500m          = %.3f\n', E_300m_500m);
fprintf(1, 'E_300m_500m_cooling  = %.3f\n', E_300m_500m_cooling);
fprintf(1, '----------------------------------------------------------\n');
fprintf(1, 'E_1000m_20m          = %.3f\n', E_1000m_20m);
fprintf(1, 'E_1000m_20m_cooling  = %.3f\n', E_1000m_20m_cooling);
fprintf(1, 'E_1000m_500m         = %.3f\n', E_1000m_500m);
fprintf(1, 'E_1000m_500m_cooling = %.3f\n', E_1000m_500m_cooling);
fprintf(1, '----------------------------------------------------------\n');
