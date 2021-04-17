k_rock = 2.87;
Cp_rock = 725;
rho_rock = 2707;
T_surface = 6.764;
q_geothermal = 40.548;

% model = init_axisymmetric_model(T_surface, q_geothermal, k_rock, Cp_rock, rho_rock, 16.25, 150);
% model.sol('sol1').runAll();
% mphsave(model, 'axisymmetric_model_150m.mph');
%     
% model = init_axisymmetric_model(T_surface, q_geothermal, k_rock, Cp_rock, rho_rock, 32.70, 300);
% model.sol('sol1').runAll();
% mphsave(model, 'axisymmetric_model_300m.mph');
% 
% model = init_axisymmetric_model(T_surface, q_geothermal, k_rock, Cp_rock, rho_rock, 109.00, 1000);
% model.sol('sol1').runAll();
% mphsave(model, 'axisymmetric_model_1000m.mph');

model = init_150m_model(T_surface, q_geothermal, k_rock, Cp_rock, rho_rock, 4.87, 20);
model.sol('sol1').runAll();
mphsave(model, 'borefield_model_150m.mph');

model = init_300m_model(T_surface, q_geothermal, k_rock, Cp_rock, rho_rock, 9.14, 20);
model.sol('sol1').runAll();
mphsave(model, 'borefield_model_300m.mph');

model = init_1000m_model(T_surface, q_geothermal, k_rock, Cp_rock, rho_rock, 30.52, 20);
model.sol('sol1').runAll();
mphsave(model, 'borefield_model_1000m.mph');
