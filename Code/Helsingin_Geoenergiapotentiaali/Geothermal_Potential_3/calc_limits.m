model = init_1000m_model(50);

options = optimset('display', 'iter', 'tolx', 0.1);

k_rock = 3.20;
Cp_rock = 721;
rho_rock = 2640;
T_surface = 6.618;
q_geothermal = 40.547;

model.param.set('k_rock', sprintf('%.3f[W/(m*K)]', k_rock));
model.param.set('Cp_rock', sprintf('%.3f[J/(kg*K)]', Cp_rock));
model.param.set('rho_rock', sprintf('%.3f[kg/m^3]', rho_rock));
model.param.set('T_surface', sprintf('%.3f[degC]', T_surface));
model.param.set('q_geothermal', sprintf('%.3f[mW/m^2]', q_geothermal));

obj_func = @(x) abs(eval_min_temp(model, x));

E_borehole = fminbnd(obj_func, 1, 100, options);

fprintf(1, 'min: k_rock=%.2f Cp_rock=%.0f rho_rock=%.0f T_surface=%.3f q_geothermal=%.3f E_borehole=%.3f\n', k_rock, Cp_rock, rho_rock, T_surface, q_geothermal, E_borehole);

k_rock = 2.66;
Cp_rock = 731;
rho_rock = 2906;
T_surface = 7.134;
q_geothermal = 42.208;

model.param.set('k_rock', sprintf('%.3f[W/(m*K)]', k_rock));
model.param.set('Cp_rock', sprintf('%.3f[J/(kg*K)]', Cp_rock));
model.param.set('rho_rock', sprintf('%.3f[kg/m^3]', rho_rock));
model.param.set('T_surface', sprintf('%.3f[degC]', T_surface));
model.param.set('q_geothermal', sprintf('%.3f[mW/m^2]', q_geothermal));

obj_func = @(x) abs(eval_min_temp(model, x));

E_borehole = fminbnd(obj_func, 1, 100, options);

fprintf(1, 'max: k_rock=%.2f Cp_rock=%.0f rho_rock=%.0f T_surface=%.3f q_geothermal=%.3f E_borehole=%.3f\n', k_rock, Cp_rock, rho_rock, T_surface, q_geothermal, E_borehole);
