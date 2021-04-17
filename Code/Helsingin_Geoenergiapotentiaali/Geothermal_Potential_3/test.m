k_rock = 3.10;
Cp_rock = 723;
rho_rock = 2794;
T_surface = 6.892;
q_geothermal = 41.390;
E_borehole = 53.237;

model = init_1000m_model();

model.param.set('k_rock', sprintf('%.3f[W/(m*K)]', k_rock));
model.param.set('Cp_rock', sprintf('%.3f[J/(kg*K)]', Cp_rock));
model.param.set('rho_rock', sprintf('%.3f[kg/m^3]', rho_rock));
model.param.set('T_surface', sprintf('%.3f[degC]', T_surface));
model.param.set('q_geothermal', sprintf('%.3f[mW/m^2]', q_geothermal));
model.param.set('annual_energy_demand', sprintf('%.30f[MW*h]', E_borehole));

model.sol('sol1').runAll();

mphsave(model, 'model_1000m.mph');
