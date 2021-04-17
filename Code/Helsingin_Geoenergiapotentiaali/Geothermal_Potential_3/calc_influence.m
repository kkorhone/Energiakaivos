clc

clear all
close all

k_rock = 2.87;
Cp_rock = 725;
rho_rock = 2707;
T_surface = 6.764;
q_geothermal = 40.548;

% Borehole field 150 m model ----------------------------------------------

% model = init_150m_model();
% 
% model.param.set('k_rock', sprintf('%.3f[W/(m*K)]', k_rock));
% model.param.set('Cp_rock', sprintf('%.3f[J/(kg*K)]', Cp_rock));
% model.param.set('rho_rock', sprintf('%.3f[kg/m^3]', rho_rock));
% model.param.set('T_surface', sprintf('%.3f[degC]', T_surface));
% model.param.set('q_geothermal', sprintf('%.3f[mW/m^2]', q_geothermal));
% 
% options = optimset('display', 'iter', 'tolx', 0.1);
% 
% obj_func = @(x) abs(eval_min_temp(model, x));
% 
% E1 = fminbnd(obj_func, 0, 100, options);
% 
% model.param.set('annual_energy_demand', sprintf('%.30f[MW*h]', E1));
% 
% mphsave(model, 'boreholefield_model_150m.mph');

% Axisymmetric 150 m model ------------------------------------------------

% model = init_axisymmetric_model(T_surface, q_geothermal, k_rock, Cp_rock, rho_rock, 150);
% 
% options = optimset('display', 'iter', 'tolx', 0.1);
% 
% obj_func = @(x) abs(eval_min_temp(model, x));
% 
% E2 = fminbnd(obj_func, 0, 100, options);
% 
% model.param.set('annual_energy_demand', sprintf('%.30f[MW*h]', E2));
% 
% mphsave(model, 'axisymmetric_model_150m.mph');

% Results for 150 m models ------------------------------------------------

% fprintf(1, ' 150 m: E1=%.6f E2=%.6f\n', E1, E2);

% Borehole field 300 m model ----------------------------------------------

% model = init_300m_model();
% 
% model.param.set('k_rock', sprintf('%.3f[W/(m*K)]', k_rock));
% model.param.set('Cp_rock', sprintf('%.3f[J/(kg*K)]', Cp_rock));
% model.param.set('rho_rock', sprintf('%.3f[kg/m^3]', rho_rock));
% model.param.set('T_surface', sprintf('%.3f[degC]', T_surface));
% model.param.set('q_geothermal', sprintf('%.3f[mW/m^2]', q_geothermal));
% 
% options = optimset('display', 'iter', 'tolx', 0.1);
% 
% obj_func = @(x) abs(eval_min_temp(model, x));
% 
% E3 = fminbnd(obj_func, 0, 100, options);
% 
% model.param.set('annual_energy_demand', sprintf('%.30f[MW*h]', E3));
% 
% mphsave(model, 'boreholefield_model_300m.mph');

% Axisymmetric 300 m model ------------------------------------------------

% model = init_axisymmetric_model(T_surface, q_geothermal, k_rock, Cp_rock, rho_rock, 300);
% 
% options = optimset('display', 'iter', 'tolx', 0.1);
% 
% obj_func = @(x) abs(eval_min_temp(model, x));
% 
% E4 = fminbnd(obj_func, 0, 100, options);
% 
% model.param.set('annual_energy_demand', sprintf('%.30f[MW*h]', E4));
% 
% mphsave(model, 'axisymmetric_model_300m.mph');

% Results for 300 m models ------------------------------------------------

% fprintf(1, ' 300 m: E3=%.6f E4=%.6f\n', E3, E4);

% Borehole field 1000 m model ---------------------------------------------

model = init_1000m_model();

model.param.set('k_rock', sprintf('%.3f[W/(m*K)]', k_rock));
model.param.set('Cp_rock', sprintf('%.3f[J/(kg*K)]', Cp_rock));
model.param.set('rho_rock', sprintf('%.3f[kg/m^3]', rho_rock));
model.param.set('T_surface', sprintf('%.3f[degC]', T_surface));
model.param.set('q_geothermal', sprintf('%.3f[mW/m^2]', q_geothermal));

options = optimset('display', 'iter', 'tolx', 0.1);

obj_func = @(x) abs(eval_min_temp(model, x));

E5 = fminbnd(obj_func, 0, 150, options);

model.param.set('annual_energy_demand', sprintf('%.30f[MW*h]', E5));

mphsave(model, 'boreholefield_model_1000m.mph');

% Axisymmetric 1000 m model -----------------------------------------------

model = init_axisymmetric_model(T_surface, q_geothermal, k_rock, Cp_rock, rho_rock, 1000);

options = optimset('display', 'iter', 'tolx', 0.1);

obj_func = @(x) abs(eval_min_temp(model, x));

E6 = fminbnd(obj_func, 0, 150, options);

model.param.set('annual_energy_demand', sprintf('%.30f[MW*h]', E6));

mphsave(model, 'axisymmetric_model_1000m.mph');

% Results for 1000 m models -----------------------------------------------

fprintf(1, '1000 m: E5=%.6f E6=%.6f\n', E5, E6);

%  150 m: E1= 4.873753 E2= 16.245850
%  300 m: E3= 9.140359 E4= 32.698775
% 1000 m: E5=30.521425 E6=108.996811

E1= 4.873753; E2= 16.245850;
E3= 9.140359; E4= 32.698775;
E5=30.521425; E6=108.996811;

fprintf('150m: %.2f (%.2f) %.0f (%.0f)\n',[E2, E1, 1000*E2/150, 1000*E1/150]);
fprintf('150m: %.2f (%.2f) %.0f (%.0f)\n',[E4, E3, 1000*E4/300, 1000*E3/300]);
fprintf('150m: %.2f (%.2f) %.0f (%.0f)\n',[E6, E5, 1000*E6/1000, 1000*E5/1000]);
